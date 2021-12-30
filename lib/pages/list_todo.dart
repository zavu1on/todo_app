import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart';
import 'package:todo_list/store.dart';
import 'package:todo_list/types.dart';

class ListTodoPage extends StatefulWidget {
  final int tabId;

  const ListTodoPage({required this.tabId, Key? key}) : super(key: key);

  @override
  _ListTodoPageState createState() => _ListTodoPageState(tabId: tabId);
}

class _ListTodoPageState extends State<ListTodoPage> {
  final int tabId;
  String inputValue = '';

  _ListTodoPageState({required this.tabId}) : super();

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(title: const Text('Todo List')),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: tabId,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.close),
            title: Text('Uncompleted'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.done),
            title: Text('Completed'),
          ),
        ],
        onTap: (int index) {
          Navigator.push(context, MaterialPageRoute(
            builder: (context) => ListTodoPage(tabId: index),
          ));
        },
      ),
      body: FutureBuilder(
        future: fetchTodos(context),
        builder: (futureContext, AsyncSnapshot snapshot) {
          return BlocBuilder<TodoCubit, List<Todo>>(
            builder: (context, state) {
              if (snapshot.hasData) {
                context.read<TodoCubit>().fetchTodos(snapshot.data);
                if (state.isNotEmpty) {
                  state = state.where((element) => element.completed == (tabId == 0 ? false : true)).toList();

                  return Padding(
                    padding: const EdgeInsets.all(8),
                    child: ListView.builder(
                      itemCount: state.length,
                      itemBuilder: (itemContext, int index) {
                        var todo = state[index];

                        return Dismissible(
                          key: Key(todo.id.toString()),
                          child: Card(
                            child: ListTile(
                              title: Text(todo.title),
                              trailing: const Icon(Icons.delete_sweep),
                              leading: CircleAvatar(
                                backgroundColor: Colors.blueAccent,
                                child: Text('${index+1}'),
                              ),
                            ),
                          ),
                          onDismissed: (direction) {
                            context.read<TodoCubit>().deleteTodo(todo.id);
                          },
                        );
                      },
                    ),
                  );
                }
              }

              return const Center(child: CircularProgressIndicator());
            },
          );
        }
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: const Text('Add Todo'),
                  content: TextField(
                    onChanged: (String value) => setState(() {
                      inputValue = value;
                    })
                  ),
                  actions: [
                    ElevatedButton(
                      child: const Text('Add'),
                      onPressed: () {
                        context.read<TodoCubit>().addTodo(inputValue);
                        Navigator.of(context).pop();
                      },
                    )
                  ],
                );
              }
          );
        },
      ),
    );
  }

  Future fetchTodos(BuildContext context) async {
    if (context.read<TodoCubit>().state.isNotEmpty) {
      return context.read<TodoCubit>().state;
    }

    Response response = await get(Uri.parse('https://jsonplaceholder.typicode.com/todos/?_limit=20'));
    var body = json.decode(response.body);
    List<Todo> qs = [];

    for (int i=0; i < body.length; i++) {
      qs.add(Todo(
        body[i]['id'],
        body[i]['userId'],
        body[i]['title'],
        body[i]['completed'],
      ));
    }

    return qs;
  }
}
