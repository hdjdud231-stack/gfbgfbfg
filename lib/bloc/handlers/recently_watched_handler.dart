import "dart:async";

import "package:flutter_bloc/flutter_bloc.dart";
import "package:logger/logger.dart";
import "package:index/bloc/app_event.dart";
import "package:index/bloc/app_state.dart";
import "package:index/bloc/handlers/helpers.dart";
import "package:index/models/movie.dart";
import "package:index/models/tv_show.dart";
import "package:index/models/watch_progress.dart";
import "package:index/enums/media_type.dart";
import "package:index/services/recently_watched_service.dart";

mixin RecentlyWatchedHandler on Bloc<AppEvent, AppState> {
  final Logger _logger = Logger();
  final RecentlyWatchedService _recentlyWatchedService = RecentlyWatchedService();
  late final HandlerHelpers _helpers = HandlerHelpers();

  Future<void> onLoadRecentlyWatched(LoadRecentlyWatched event, Emitter<AppState> emit) async {
    if ((state.recentlyWatchedMovies != null && state.recentlyWatchedTvShows != null) || state.isLoadingRecentlyWatched) {
      return;
    }

    emit(state.copyWith(
      isLoadingRecentlyWatched: true,
      error: null,
    ));

    try {
      final List<WatchProgress> recentlyWatched = await _recentlyWatchedService.getRecentlyWatched();

      final List<int> movieIds = recentlyWatched
          .where((item) => item.mediaType == MediaType.movies.toJsonField())
          .map<int>((item) => item.mediaId)
          .toList();
      final List<int> tvShowIds = recentlyWatched
          .where((item) => item.mediaType == MediaType.tvShows.toJsonField())
          .map<int>((item) => item.mediaId)
          .toList();

      final List<Movie> recentlyWatchedMovies = await _helpers.fetchMoviesByIds(state, movieIds);
      final List<TvShow> recentlyWatchedTvShows = await _helpers.fetchTvShowsByIds(state, tvShowIds);

      emit(state.copyWith(
        recentlyWatched: recentlyWatched,
        recentlyWatchedMovies: recentlyWatchedMovies,
        recentlyWatchedTvShows: recentlyWatchedTvShows,
        isLoadingRecentlyWatched: false,
      ));
    } catch (e, s) {
      _logger.e("Error loading recently watched", error: e, stackTrace: s);
      emit(state.copyWith(
        isLoadingRecentlyWatched: false,
        error: "Failed to load recently watched",
      ));
    }
  }

  Future<void> onRefreshRecentlyWatched(RefreshRecentlyWatched event, Emitter<AppState> emit) async {
    emit(state.copyWith(
      recentlyWatched: null,
      recentlyWatchedMovies: null,
      recentlyWatchedTvShows: null,
      isLoadingRecentlyWatched: false,
    ));
    add(LoadRecentlyWatched());
  }

  Future<void> onUpdateMovieProgress(UpdateMovieProgress event, Emitter<AppState> emit) async {
    try {
      await _recentlyWatchedService.updateMovieProgress(event.movieId, event.movie.title, event.movie.posterPath, event.progress, event.duration);
      final List<Movie> updatedRecentlyWatchedMovies = state.recentlyWatchedMovies ?? <Movie>[];

      if (state.recentlyWatchedMovies != null && !state.recentlyWatchedMovies!.any((Movie movie) => movie.id == event.movieId)) {
        final Movie? movie = await _helpers.fetchMovieById(state, event.movieId);
        if (movie != null) {
          updatedRecentlyWatchedMovies.add(movie);
        }
      }

      emit(state.copyWith(
        recentlyWatchedMovies: updatedRecentlyWatchedMovies,
      ));
    } catch (e, s) {
      _logger.e("Error updating movie progress", error: e, stackTrace: s);
      emit(state.copyWith(
        error: "Failed to update movie progress",
      ));
    }
  }

  Future<void> onUpdateEpisodeProgress(UpdateEpisodeProgress event, Emitter<AppState> emit) async {
    try {
      await _recentlyWatchedService.updateEpisodeProgress(
        event.tvShowId,
        event.tvShow.name,
        event.tvShow.posterPath,
        event.seasonId,
        event.episodeId,
        event.progress,
        event.duration,
      );
      final List<TvShow> updatedRecentlyWatchedTvShows = state.recentlyWatchedTvShows ?? <TvShow>[];

      if (state.recentlyWatchedTvShows != null && !state.recentlyWatchedTvShows!.any((TvShow tvShow) => tvShow.id == event.tvShowId)) {
        final TvShow? tvShow = await _helpers.fetchTvShowById(state, event.tvShowId);
        if (tvShow != null) {
          updatedRecentlyWatchedTvShows.add(tvShow);
        }
      }

      emit(state.copyWith(
        
        recentlyWatchedTvShows: updatedRecentlyWatchedTvShows,
      ));
    } catch (e, s) {
      _logger.e("Error updating episode progress", error: e, stackTrace: s);
      emit(state.copyWith(
        error: "Failed to update episode progress",
      ));
    }
  }

  Future<void> onDeleteMovieProgress(DeleteMovieProgress event, Emitter<AppState> emit) async {
    try {
      await _recentlyWatchedService.removeMovie(event.movieId);
      final List<Movie> updatedRecentlyWatchedMovies = state.recentlyWatchedMovies?.where((Movie movie) => movie.id != event.movieId).toList() ?? <Movie>[];

      emit(state.copyWith(
        recentlyWatchedMovies: updatedRecentlyWatchedMovies,
      ));
    } catch (e, s) {
      _logger.e("Error deleting movie progress", error: e, stackTrace: s);
      emit(state.copyWith(
        error: "Failed to delete movie progress",
      ));
    }
  }

  Future<void> onDeleteEpisodeProgress(DeleteEpisodeProgress event, Emitter<AppState> emit) async {
    try {
      await _recentlyWatchedService.removeEpisodeProgress(
        event.tvShowId,
        event.seasonId,
        event.episodeId,
      );
      final List<TvShow> updatedRecentlyWatchedTvShows = state.recentlyWatchedTvShows?.where((TvShow tvShow) => tvShow.id != event.tvShowId).toList() ?? <TvShow>[];

      emit(state.copyWith(
        
        recentlyWatchedTvShows: updatedRecentlyWatchedTvShows,
      ));
    } catch (e, s) {
      _logger.e("Error deleting episode progress", error: e, stackTrace: s);
      emit(state.copyWith(
        error: "Failed to delete episode progress",
      ));
    }
  }

  Future<void> onDeleteTvShowProgress(DeleteTvShowProgress event, Emitter<AppState> emit) async {
    try {
      await _recentlyWatchedService.removeTvShow(
        event.tvShowId,
      );
      final List<TvShow> updatedRecentlyWatchedTvShows = state.recentlyWatchedTvShows?.where((TvShow tvShow) => tvShow.id != event.tvShowId).toList() ?? <TvShow>[];

      emit(state.copyWith(
        
        recentlyWatchedTvShows: updatedRecentlyWatchedTvShows,
      ));
    } catch (e, s) {
      _logger.e("Error deleting TV show progress", error: e, stackTrace: s);
      emit(state.copyWith(
        error: "Failed to delete TV show progress",
      ));
    }
  }

  Future<void> onHideTvShowProgress(HideTvShowProgress event, Emitter<AppState> emit) async {
    try {
      await _recentlyWatchedService.hideTvShow(
        event.tvShowId,
      );
      final List<TvShow> updatedRecentlyWatchedTvShows = state.recentlyWatchedTvShows?.where((TvShow tvShow) => tvShow.id != event.tvShowId).toList() ?? <TvShow>[];

      emit(state.copyWith(
        
        recentlyWatchedTvShows: updatedRecentlyWatchedTvShows,
      ));
    } catch (e, s) {
      _logger.e("Error hiding TV show progress", error: e, stackTrace: s);
      emit(state.copyWith(
        error: "Failed to hide TV show progress",
      ));
    }
  }

  void onClearRecentlyWatched(ClearRecentlyWatched event, Emitter<AppState> emit) {
    try {
      unawaited(_recentlyWatchedService.clear());
    } catch (e, s) {
      _logger.e("Error clearing recently watched", error: e, stackTrace: s);
    }

    emit(state.copyWith(
      recentlyWatched: <String, dynamic>{},
      recentlyWatchedMovies: <Movie>[],
      recentlyWatchedTvShows: <TvShow>[],
    ));
  }
}