import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:news_app_bloc/bloc/newsBloc.dart';
import 'package:news_app_bloc/model/newsmodel.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class Homepage extends StatefulWidget {
  const Homepage({Key? key}) : super(key: key);

  @override
  _HomepageState createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  final _newsBloc = NewsBloc();
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  @override
  void initState() {
    super.initState();
    _newsBloc.eventSink.add(NewsAction.Fetch);
  }

  void _onRefresh() async {
    // monitor network fetch
    await Future.delayed(Duration(milliseconds: 1000));
    // if failed,use refreshFailed()
    _newsBloc.eventSink.add(NewsAction.Fetch);
    _refreshController.refreshCompleted();
  }

  @override
  Widget build(BuildContext context) {
    print("------built-----");
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text("News App"),
        centerTitle: true,
      ),
      body: StreamBuilder<List<Articles>>(
          stream: _newsBloc.newsStream,
          builder: (context, snapshot) {
            print(snapshot.data);
            if (snapshot.hasData) {
              return SmartRefresher(
                enablePullDown: true,
                enablePullUp: true,
                // header: WaterDropHeader(),
                controller: _refreshController,
                onRefresh: _onRefresh,
                child: ListView.builder(
                    itemCount: snapshot.data?.length,
                    itemBuilder: (context, index) {
                      var article = snapshot.data![index];
                      DateTime date = DateTime.parse(article.publishedAt ?? "");
                      var formattedTime =
                          DateFormat("EE dd MMM - HH:mm a").format(date);

                      return Container(
                          decoration: BoxDecoration(
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(color: Colors.grey, blurRadius: 0.1),
                              ],
                              borderRadius: BorderRadius.circular(15)),
                          margin:
                              EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          padding: EdgeInsets.symmetric(
                              horizontal: 10, vertical: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: SizedBox(
                                      width: 50,
                                      height: 50,
                                      child: Image.network(
                                        article.urlToImage ?? "",
                                        errorBuilder: (_, __, ___) {
                                          return Icon(Icons.error);
                                        },
                                      ))),
                              SizedBox(
                                width: 20,
                              ),
                              SizedBox(
                                width: size.width * 0.7,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    Text(formattedTime),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Text(article.title ?? ""),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Text(article.description ?? "")
                                  ],
                                ),
                              )
                            ],
                          ));
                    }),
              );
            } else {
              return Center(child: CircularProgressIndicator());
            }
          }),
    );
  }
}
