import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo_list/types.dart';

class TodoCubit extends Cubit<List<Todo>> {
  TodoCubit() : super([]);

  fetchTodos(List<Todo> todos) {
    if (state.isEmpty) {
      emit(todos);
    }
  }

  deleteTodo(int id) {
    emit(state.where((element) => element.id != id).toList());
  }

  addTodo(String title) {
    state.add(Todo(DateTime.now().millisecondsSinceEpoch, 1, title, false));
    emit(state);
  }
}