import 'package:flutter/material.dart';

class ExploreScreen extends StatefulWidget {
  // Define just a super basic example list that will be searched on because it is passed into SearcH method

  // WARNIng THE SEARCH IS CASE SENSITIVE
  //final List<String> list = List.generate(10, (index) => "text $index");
  final List<String> list = [
    "evie kiehfuss",
    "james fleming",
    "sudharsan balasubramani",
    "henry fleming",
    "sailesh balasubramani",
    "poop pants in my poop",
    "david bowie",
    "steve jobs",
    "mark zuck zuck 9000",
    "dr dre"
  ];
  @override
  _ExploreScreenState createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  @override
  Widget build(BuildContext context) {
    // Here we build the explore page.
    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.search),
              onPressed: () {
                // Call show search and  pass context and delegate
                showSearch(context: context, delegate: Search(widget.list));
              })
        ],
        title: Text("Explore"),
      ),
      body: Text(
          "We can put anything here. Suggested places, friends, most visited place in area by friends that you have not visited etcc"),
    );
  }
}

class Search extends SearchDelegate {
  @override

  // Returns a list of widgets that go on the right side of the text field
  List<Widget> buildActions(BuildContext context) {
    // Create a single widget that clears query text with close icon
    return <Widget>[
      IconButton(
        icon: Icon(Icons.close),
        onPressed: () {
          // Query is the text of the built in text field of a search page
          query = "";
        },
      ),
    ];
  }

  @override
  // Single widget on left of search field
  Widget buildLeading(BuildContext context) {
    // Build arrow_back with a navigator.pop()
    // This will take us out of the search page and back to explore page.
    return IconButton(
      icon: Icon(Icons.arrow_back_ios_rounded),
      onPressed: () {
        Navigator.pop(context);
      },
    );
  }

  String selectedResult = "";
  @override
  Widget buildResults(BuildContext context) {
    // Once show result is called this function build results returns a widget to cover the body of a scaffold
    /// following the website for now, not sure what really goes here
    /// I'm pretty sure this is what is built once you actually select an option
    /// How we get it to redirect to a profile... I'm not sure. Hoping reusable widgets or something :)
    // For now just some filler

    return Container(
      child: Center(
        child: Text(selectedResult),
      ),
    );
  }

  // This will be our recentList, it will show when we don't yet have a full query ready
  List<String> recentList = ["Poopy pants", "poopy poopity pants"];

  // Here will will create a variable and constructor to take in an InputtedList

  final List<String> listIn;
  Search(this.listIn);
  // AS a next step we can pass in a list of all usernames to here.
  @override
  Widget buildSuggestions(BuildContext context) {
    // This is the list we want to populate
    List<String> suggestionList = [];
    // Check if query is 2 or longer or for  now just check if it is empty
    // Maybe in future if we are using shingles we can make sure search is of certain lenght
    (query.isEmpty)
        ? suggestionList = recentList
        // Here when query is long enough we see the most basic search function happening
        // Searches through everything in list and keeps the ones that contain the query
        // Linear time, not very fast for a bunch of usernames but a proof of concept is nice
        // IN the future instead of doing searching here, we call an external function that returns a list
        // and sett suggestionList to that.

        // WARNING "where" is case sensitive
        : suggestionList.addAll(listIn.where(
            (element) => element.contains(query.toLowerCase()),
          ));

    // Here we build the list based on whatever suggestionList is set to
    return ListView.builder(
      itemCount: suggestionList.length,
      itemBuilder: (context, index) {
        return ListTile(
            title: Text(
              suggestionList[index],
            ),
            onTap: () {
              // If we tap one of the list results,
              // Set the selected result and call showResults to utilize the buildResults method
              selectedResult = suggestionList[index];
              showResults(context);
            });
      },
    );
  }
}
