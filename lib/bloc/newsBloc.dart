import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:news_app_bloc/model/newsmodel.dart';

class NewsBloc {
  final _newsBlocController = new StreamController<List<Articles>>();
  StreamSink<List<Articles>> get _newsSink => _newsBlocController.sink;
  Stream<List<Articles>> get newsStream => _newsBlocController.stream;

  final _eventBlocController = new StreamController<NewsAction>();
  StreamSink<NewsAction> get eventSink => _eventBlocController.sink;
  Stream<NewsAction> get _eventStream => _eventBlocController.stream;

  NewsBloc() {
    _eventStream.listen((event) async {
      if (event == NewsAction.Fetch) {
        try {
          var news = await getNews();
          _newsSink.add(news.articles ?? []);
        } on Exception catch (_) {
          _newsSink.addError("Something happened");
        }
      }
    });
  }
  Future<NewsModel> getNews() async {
    var newsModel;
    try {
      var response = await http.get(Uri.parse(
          "https://newsapi.org/v2/top-headlines?country=in&apiKey=166ffae5515f4216b89f6ecd36c867b9"));
      if (response.statusCode == 200) {
        var body = response.body;
        var jsonMap = json.decode(body);

        newsModel = NewsModel.fromJson(jsonMap);
      }
    } on Exception catch (_) {
      return newsModel;
    }
    return newsModel;
  }

  void dispose() {
    _newsBlocController.close();
    _eventBlocController.close();
  }
}

enum NewsAction { Fetch, Delete }
