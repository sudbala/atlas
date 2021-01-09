import 'package:atlas/screens/CustomAppBar.dart';
import 'package:flutter/material.dart';
import 'package:atlas/screens/ProfileScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ExploreScreen extends StatefulWidget {
  // Define just a super basic example list that will be searched on because it is passed into SearcH method

  // WARNIng THE SEARCH IS CASE SENSITIVE
  //final List<String> list = List.generate(10, (index) => "text $index");
  final List<String> list = [
    "evie kiehfuss",
    "james fleming",
    "sudharsan balasubramani",
    "henry fleming",
    "sailesh bala",
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
      appBar: CustomAppBar(
          "Explore",
          <Widget>[
            IconButton(
                icon: Icon(Icons.search),
                // THis is what happens when we click on the search Icon
                onPressed: () async {
                  // Call show search and  pass context and delegate
                  final result = await showSearch(
                      context: context, delegate: Search(widget.list));
                  if (result != null) {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (BuildContext context) {
                          return ProfileScreen(result);
                        },
                      ),
                    );
                  }
                })
          ],
          context,
          Container()),
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

  // Here will will create a variable and constructor to take in an InputtedList
  final List<String> listIn;
  Search(this.listIn);

  // Suggestion list will be built based off of the query going through
  // listIn
  List<String> suggestionList = [];
  List<String> idList = [];

  //

  String selectedResult = "";
  @override
  Widget buildResults(BuildContext context) {
    // Our result list is identical to our suggestion list
    return ListView.builder(
      itemCount: suggestionList.length,
      itemBuilder: (context, index) {
        return ListTile(
            title: Text(
              suggestionList[index],
            ),
            onTap: () {
              // When we click on a result, push a profile page to the navigator
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (BuildContext context) {
                    // We will push a ProfileScreen and pass in
                    // SuggestionList[index] which is the search result that we selected
                    return ProfileScreen(idList[index]);
                  },
                ),
              );
            });
      },
    );
  }

  // This will be our recentList, it will show when we don't yet have a full query ready
  // Needs to be built in the future, for now, no need to worry about it.
  List<String> recentList = ["Press Enter to Search"];

  Future<List<String>> queryUsers(String queryString) async {
    List<String> mySuggestionList = [];
    idList = [];
    if (queryString.isNotEmpty) {
      List<QueryDocumentSnapshot> documentList = (await FirebaseFirestore
              .instance
              .collection('Users') // We will perform two queries
              // I found this off an example online and honestly not sure what it really does
              // By no means perfect or even fast searching but does the job
              .where('UserName', isGreaterThanOrEqualTo: queryString)
              .where('UserName', isLessThan: queryString + 'z')
              .get()) // Grab the QuerydocumentSnapshots from these
          .docs;
/* Add query for Name in addition to userName? not sure why this isn't working, maybe need a set so there are not duplicates
      documentList.addAll((await FirebaseFirestore.instance
              .collection("Users")
              .where('Name', isGreaterThanOrEqualTo: queryString)
              .where('Name', isLessThan: queryString + 'z')
              .get())
          .docs);

          */
      // Go through each document we get and add to suggestionList
      // and id list
      documentList.forEach((QueryDocumentSnapshot doc) {
        // Add userName field for this doc
        mySuggestionList.add(doc.get("UserName"));
        // Add id of this doc which is the userId
        idList.add(doc.id);
      });
    }
    return mySuggestionList;
  }

  // buildSuggestions is called everytime the user types a new character for "automatic" search
  @override
  Widget buildSuggestions(BuildContext context) {
    // Method to populate the suggestion List

    // This is the list we want to populate

    //showResults(context);

    // Here we build the list based on whatever suggestionList is set to
    // Use a future builder so that we reset once suggestionList has been updated to whatever queryUsers returns
    return FutureBuilder<List>(
        future: queryUsers(query.toLowerCase()),
        builder: (BuildContext context, AsyncSnapshot<List> snapshot) {
          if (snapshot.hasData) {
            suggestionList = snapshot.data;
            //print(snapshot.data);
          } else if (snapshot.hasError) {
            print(snapshot.error);
          } else {
            suggestionList = [];
          }
          return ListView.builder(
            itemCount: suggestionList.length,
            itemBuilder: (context, index) {
              return ListTile(
                  title: Text(
                    suggestionList[index],
                  ),
                  onTap: () {
                    // If we tap one of the list results,
                    // Set the selected result
                    selectedResult = suggestionList[index];
                    // Switch the list to the results list
                    //showResults(context);

                    // immediately head off to the correct profile photo. No need to tap the "results" again

                    // The hack we are using is that our "suggestions" are actually the results we are looking for.
                    // Notice most social medias do it this way. Searches instantly update as you type. Pressing search does nothing but putting the text screen down

                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (BuildContext context) {
                          // Return the profile page of the associated id.
                          return ProfileScreen(idList[index]);
                        },
                      ),
                    );
                  });
            },
          );
        });
  }
}
