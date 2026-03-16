async function loadUsers() {

    let res = await fetch("/api/users");
    let users = await res.json();

    let list = document.getElementById("userList");
    list.innerHTML = "";

    users.forEach(u => {
        let li = document.createElement("li");
        li.innerText = u;
        list.appendChild(li);
    });

}

async function addUser(){

    let name = document.getElementById("username").value;

    await fetch("/api/users",{
        method:"POST",
        headers:{
            "Content-Type":"application/json"
        },
        body:JSON.stringify({name:name})
    });

    loadUsers();
}

loadUsers();
