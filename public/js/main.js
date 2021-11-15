// Selectors

const toDoInput = document.querySelector('.todo-input');
const toDoBtn = document.querySelector('.todo-btn');
const toDoList = document.querySelector('.todo-list');
const standardTheme = document.querySelector('.standard-theme');

// Event Listeners
toDoBtn.addEventListener('click', addToDo);
toDoList.addEventListener('click', deletecheck);
document.addEventListener("DOMContentLoaded", getTodos);
standardTheme.addEventListener('click', () => setTheme('standard'));
setTheme('standard');  // Default theme

// Functions;
function addToDo(event) {
    // Prevents form from submitting / Prevents form from relaoding;
    event.preventDefault();

    // toDo DIV;
    const toDoDiv = document.createElement("div");
    toDoDiv.classList.add('todo', 'standard-todo');

    // Create LI
    const newToDo = document.createElement('li');
    if (toDoInput.value === '') {
            alert("You must write something!");
        }
    else {
        // newToDo.innerText = "hey";
        $.ajax({
            // url to make request
            url:'/api/v1/todo',
            // Type of Request
            type: "POST",
            contentType: "application/json",
            data: JSON.stringify({description: toDoInput.value}),
            // Function to call when to

            // request is ok
            success: function (data) {
                console.log("Successfully Created"+ data);

                newToDo.innerText = toDoInput.value;
                newToDo.classList.add('todo-item');
                newToDo.setAttribute('id', data['reference_id']);
                toDoDiv.appendChild(newToDo);
                // check btn;
                const checked = document.createElement('button');
                checked.innerHTML = '<i class="fas fa-check"></i>';
                checked.classList.add('check-btn', 'standard-button');
                toDoDiv.appendChild(checked);
                // delete btn;
                const deleted = document.createElement('button');
                deleted.innerHTML = '<i class="fas fa-trash"></i>';
                deleted.classList.add('delete-btn', 'standard-button');
                toDoDiv.appendChild(deleted);
        
                // Append to list;
                toDoList.appendChild(toDoDiv);
        
                // CLearing the input;
                toDoInput.value = '';
            },
            // Error handling
            error: function (error) {
                console.log(`Error ${error}`);
            }
        });
    }

}


function deletecheck(event){

    const item = event.target;
    var reference_id = item.parentElement.firstChild.id;

    // Delete todo
    // delete
    if(item.classList[0] === 'delete-btn')
    {
        // item.parentElement.remove();
        // animation
        item.parentElement.classList.add("fall");

        //removing local todos;
        $.ajax({
            // url to make request
            url:'/api/v1/todo/' + reference_id,
            // Type of Request
            type: "DELETE",
            // Function to call when to
            // request is ok
            success: function (data) {
                console.log("Successfully deleted");
                item.parentElement.addEventListener('transitionend', function(){
                    item.parentElement.remove();
                })
            },
            // Error handling
            error: function (error) {
                console.log(`Error ${error}`);
            }
        });

    }

    // check
    //mark as completed
    if(item.classList[0] === 'check-btn')
    {
        //removing local todos;
        item.parentElement.classList.toggle("completed");
        $.ajax({
            // url to make request
            url:'/api/v1/todo/' + reference_id,
            // Type of Request
            type: "PUT",
            // Function to call when to
            // request is ok
            success: function (data) {
                console.log("Successfully updated");
                item.parentElement.firstChild.nextElementSibling.remove();
            },
            // Error handling
            error: function (error) {
                console.log(`Error ${error}`);
            }
        });
    }

}

function getTodos() {
    //Check: if item/s are there;
    $.ajax({
        // url to make request
        url:'/api/v1/todo',
        // Type of Request
        type: "GET",
        // Function to call when to
        // request is ok
        success: function (data) {
            for(var i in data) {
                // toDo DIV;
                const toDoDiv = document.createElement("div");
                toDoDiv.classList.add("todo", 'standard-todo');

                // Create LI
                const newToDo = document.createElement('li');
                
                newToDo.innerText = data[i]['description'];
                newToDo.classList.add('todo-item');
                newToDo.setAttribute('id', data[i]['id']);
                toDoDiv.appendChild(newToDo);

                if(data[i]['status'] == 'completed') {
                    newToDo.classList.add(data[i]['status']);
                }

                // check btn; 
                // for completed items hide it
                if(data[i]['status'] != 'completed') {
                    const checked = document.createElement('button');
                    checked.innerHTML = '<i class="fas fa-check"></i>';
                    checked.classList.add("check-btn", 'standard-button-button');
                    toDoDiv.appendChild(checked);
                }

                // delete btn;
                const deleted = document.createElement('button');
                deleted.innerHTML = '<i class="fas fa-trash"></i>';
                deleted.classList.add("delete-btn",'standard-button');
                toDoDiv.appendChild(deleted);

                // Append to list;
                toDoList.appendChild(toDoDiv);
            }
        },

        // Error handling
        error: function (error) {
            console.log(`Error ${error}`);
        }
    });

}

// Change theme function:
function setTheme(color) {
    localStorage.setItem('savedTheme', color);
    savedTheme = localStorage.getItem('savedTheme');

    document.body.className = color;
    // Change blinking cursor for darker theme:
    document.getElementById('title').classList.remove('darker-title');

    document.querySelector('input').className = `${color}-input`;
    // Change todo color without changing their status (completed or not):
    document.querySelectorAll('.todo').forEach(todo => {
        Array.from(todo.classList).some(item => item === 'completed') ? 
            todo.className = `todo ${color}-todo completed`
            : todo.className = `todo ${color}-todo`;
    });
    // Change buttons color according to their type (todo, check or delete):
    document.querySelectorAll('button').forEach(button => {
        Array.from(button.classList).some(item => {
            if (item === 'check-btn') {
              button.className = `check-btn ${color}-button`;  
            } else if (item === 'delete-btn') {
                button.className = `delete-btn ${color}-button`; 
            } else if (item === 'todo-btn') {
                button.className = `todo-btn ${color}-button`;
            }
        });
    });
}