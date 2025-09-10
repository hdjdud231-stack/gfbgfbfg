import "package:flutter_bloc/flutter_bloc.dart";
import "package:index/bloc/app_event.dart";
import "package:index/bloc/app_state.dart";
import "package:index/enums/media_type.dart";

mixin GeneralHandler on Bloc<AppEvent, AppState> {
  void onLoadInitialData(LoadInitialData event, Emitter<AppState> emit) {
    add(LoadMovies());
    add(LoadTvShows());
    add(LoadStreamingPlatformsMedia());
    add(const LoadGenres(MediaType.movies));
    add(const LoadGenres(MediaType.tvShows));
    add(LoadRecentlyWatched());
    add(LoadFavorites());
    add(LoadRecentSearches());
    add(InitCacheTimer());
  }

  void onClearError(ClearError event, Emitter<AppState> emit) {
    emit(state.copyWith(
      error: null,
    ));
  }
}