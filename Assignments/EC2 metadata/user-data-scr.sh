#!/bin/bash

yum update -y
yum install -y docker git
systemctl start docker
systemctl enable docker

mkdir /dashboard
cd /dashboard

cat <<EOF > app.py
from flask import Flask, render_template, jsonify
import psutil
import requests
import time
import subprocess

app = Flask(__name__)
start_time = time.time()

BASE="http://169.254.169.254/latest"

def get_token():
    try:
        token = requests.put(
            BASE+"/api/token",
            headers={"X-aws-ec2-metadata-token-ttl-seconds":"21600"},
            timeout=2
        ).text
        return token
    except:
        return None

def meta(path):
    try:
        token=get_token()
        r=requests.get(
            BASE+"/meta-data/"+path,
            headers={"X-aws-ec2-metadata-token":token},
            timeout=2
        )
        return r.text
    except:
        return "N/A"

def docker_stats():
    try:
        out=subprocess.check_output(
        "docker stats --no-stream --format '{{.Name}} | CPU {{.CPUPerc}} | MEM {{.MemUsage}}'",
        shell=True).decode().strip()

        return out if out else "No Containers"
    except:
        return "Docker unavailable"

@app.route("/")
def index():

    metadata={
        "instance":meta("instance-id"),
        "type":meta("instance-type"),
        "az":meta("placement/availability-zone"),
        "private_ip":meta("local-ipv4")
    }

    return render_template("index.html",meta=metadata)

@app.route("/metrics")
def metrics():

    net=psutil.net_io_counters()

    uptime=int(time.time()-start_time)

    return jsonify({
        "cpu":psutil.cpu_percent(),
        "mem":psutil.virtual_memory().percent,
        "disk":psutil.disk_usage('/').percent,
        "net":net.bytes_sent+net.bytes_recv,
        "docker":docker_stats(),
        "uptime":uptime
    })

if __name__=="__main__":
    app.run(host="0.0.0.0",port=80)
EOF



mkdir templates

cat <<EOF > templates/index.html
<!DOCTYPE html>
<html>

<head>

<title>EC2 Production Monitoring</title>

<script src="https://cdn.jsdelivr.net/npm/chart.js"></script>

<style>

body{
background:#020617;
color:#e2e8f0;
font-family:system-ui;
text-align:center;
margin:0;
}

header{
background:#0f172a;
padding:20px;
font-size:28px;
color:#38bdf8;
}

.card{
background:#0f172a;
padding:20px;
margin:20px;
border-radius:12px;
box-shadow:0 0 10px rgba(0,0,0,0.5);
}

table{
margin:auto;
border-collapse:collapse;
width:60%;
}

td,th{
border:1px solid #1e293b;
padding:10px;
}

th{
background:#1e293b;
}

canvas{
max-width:700px;
margin:20px auto;
background:#020617;
padding:10px;
border-radius:10px;
}

</style>

</head>

<body>

<header>
EC2 Production Monitoring Dashboard
</header>

<div class="card">

<h2>Instance Metadata</h2>

<table>

<tr><th>Key</th><th>Value</th></tr>

<tr><td>Instance ID</td><td>{{meta.instance}}</td></tr>
<tr><td>Instance Type</td><td>{{meta.type}}</td></tr>
<tr><td>Availability Zone</td><td>{{meta.az}}</td></tr>
<tr><td>Private IP</td><td>{{meta.private_ip}}</td></tr>

</table>

</div>


<div class="card">

<h2>Instance Uptime</h2>

<h3 id="uptime">Loading...</h3>

</div>


<div class="card">

<h2>Docker Containers</h2>

<h3 id="docker">Loading...</h3>

</div>


<h2>CPU Usage</h2>
<canvas id="cpu"></canvas>

<h2>Memory Usage</h2>
<canvas id="mem"></canvas>

<h2>Disk Usage</h2>
<canvas id="disk"></canvas>

<h2>Network Traffic</h2>
<canvas id="net"></canvas>


<script>

const labels=[]
const cpu=[]
const mem=[]
const disk=[]
const net=[]

function createChart(id,label,data){

return new Chart(document.getElementById(id),{

type:'line',

data:{
labels:labels,
datasets:[{label:label,data:data}]
},

options:{
responsive:true
}

})

}

const cpuChart=createChart("cpu","CPU %",cpu)
const memChart=createChart("mem","Memory %",mem)
const diskChart=createChart("disk","Disk %",disk)
const netChart=createChart("net","Network Bytes",net)

function update(){

fetch("/metrics")

.then(r=>r.json())

.then(d=>{

let time=new Date().toLocaleTimeString()

labels.push(time)

cpu.push(d.cpu)
mem.push(d.mem)
disk.push(d.disk)
net.push(d.net)

if(labels.length>20){

labels.shift()
cpu.shift()
mem.shift()
disk.shift()
net.shift()

}

cpuChart.update()
memChart.update()
diskChart.update()
netChart.update()

let sec=d.uptime

let h=Math.floor(sec/3600)
let m=Math.floor((sec%3600)/60)
let s=sec%60

document.getElementById("uptime").innerText=
h+"h "+m+"m "+s+"s"

document.getElementById("docker").innerText=d.docker

})

}

setInterval(update,2000)

</script>

</body>

</html>
EOF


cat <<EOF > requirements.txt
flask
psutil
requests
EOF


cat <<EOF > Dockerfile
FROM python:3.11
WORKDIR /app
COPY . .
RUN pip install -r requirements.txt
EXPOSE 80
CMD ["python","app.py"]
EOF


docker build -t ec2-monitor .
docker run -d -p 80:80 --restart=always ec2-monitor