import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamx/models/object_model.dart';
import 'package:gamx/repositories/game_repository.dart';

import 'game_state.dart';

class GameCubit extends Cubit<GameState> {

  final GameRepository _gameRepository;

  GameCubit(this._gameRepository) : super(GameLoading());

  void onTapped(ObjectModel object) {
    if (object.isColored) return;

    _gameRepository.onGridTap(object, (isError) {
      if (isError) {
        emit(ItemTapError());
      }

      load();
    });
  }

  void load() {
    emit(GameLoading());

    final items = _gameRepository.showClickableItems();
    final score = _gameRepository.getScore();

    emit(GameLoaded(items, score));

    Timer(Duration(seconds: 3), () {
      final noColorItems = items.map((e) => e.hideColor()).toList();
      emit(GameLoaded(noColorItems, score));
    });
  }

  void gameOver() {
    emit(GameTimeOut());
  }
}
