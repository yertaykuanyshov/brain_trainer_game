import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamx/bloc/game_event.dart';
import 'package:gamx/models/object_model.dart';
import 'package:gamx/repositories/game_repository.dart';

import '../config.dart';
import 'game_state.dart';

class GameBloc extends Bloc<GameEvent, GameState> {
  final GameRepository _gameRepository;

  List<ObjectModel> _items = [];
  List<ObjectModel> _activeCells = [];

  int _score = 0;
  int _displayTime = Config.gameTime;

  bool _clickDisabled = true;

  GameBloc(this._gameRepository) : super(GameLoading()) {
    on<LoadGame>(loadGame);

    on<GenerateNewCells>((event, emit) {
      _clickDisabled = true;

      _items = _gameRepository.showClickableItems();
      _activeCells = _items.where((cell) => cell.isActive == true).toList();
      _score = _gameRepository.getScore();

      add(UpdateCells(_items));

      Timer(Duration(seconds: 2), () {
        add(ClearCells());
      });
    });

    on<UpdateCells>((event, emit) {
      emit(GameLoaded(event.cells, _score, _displayTime.toString()));
    });

    on<ClearCells>(clearShowedCells);

    on<ItemTapped>(checkTappedCell);
  }

  void loadGame(event, emit) {
    emit(GameInfo());

    Timer(Duration(seconds: 1), () {
      add(GenerateNewCells());

      Timer.periodic(Duration(seconds: 1), (timer) {
        final currentSecond = timer.tick;
        _displayTime = Config.gameTime - currentSecond;

        if (currentSecond > Config.gameTime) {
          emit(GameTimeOut(_score));
        } else {
          add(UpdateCells(_items));
        }
      });
    });
  }

  void clearShowedCells(event, emit) {
    _items =
        _items.map<ObjectModel>((e) => e.copyWith(isColored: false)).toList();

    _clickDisabled = false;

    add(UpdateCells(_items));
  }

  void checkTappedCell(event, emit) {
    final ObjectModel tappedCell = event.cell;

    if (tappedCell.isColored || tappedCell.isError || _clickDisabled) return;

    if (_activeCells.contains(tappedCell)) {
      _items[tappedCell.index] =
          _items[tappedCell.index].copyWith(isColored: true);
    } else {
      _items[tappedCell.index] =
          _items[tappedCell.index].copyWith(isError: true);
    }

    add(UpdateCells(_items));

    _gameRepository.onGridTap(tappedCell, () {
      Timer(Duration(milliseconds: 300), () {
        add(GenerateNewCells());
      });
    });
  }
}
