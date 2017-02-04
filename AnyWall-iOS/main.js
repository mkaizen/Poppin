
// Use Parse.Cloud.define to define as many cloud functions as you want.
// For example:
Parse.Cloud.define("hello", function(request, response) {
  response.success("Hello world!");
});

/**
 Parse.Cloud.define("find", function(request, response) {

                   //var GameScore = Parse.Object.extend("d");
                  // var query = new Parse.Query(GameScore);
                   var query = new Parse.Query("PAWPost");
                   query.equalTo("date", request.params.date);

                   query.lessThan("date",  new Date());
                   query.find({
                               success: function(object) {
                               // Successfully retrieved the object.
                               if (object) {
                               response.success("Object found with id: " + object.id);
                               } else {
                               response.error("No object found");
                               }
                               },
                               error: function(error) {
                               response.error("Query failed.");
                               }
                               });
                   });
**/
Parse.Cloud.job('deleteOldPosts', function(request, status) {

    // All access
    Parse.Cloud.useMasterKey();

    var today = new Date();
   // var days = 70;
   // var time = (days * 24 * 3600 * 1000);
   // var expirationDate = new Date(today.getTime() - (time));

    var query = new Parse.Query("Posts");
        // All posts have more than 70 days
        query.lessThan("date", today);

        query.find().then(function (Posts) {
            Parse.Object.destroyAll(Posts, {
                success: function() {
                    status.success('All posts are removed.');
                },
                error: function(error) {
                    status.error('Error, posts are not removed.');
                }
            });
        }, function (error) {});

});

Parse.Cloud.afterDelete("Posts", function(request) {
  query = new Parse.Query("comment");
  query.equalTo("commentPost", request.object);
  query.find({
    success: function(comments) {
      Parse.Object.destroyAll(comments, {
        success: function() {},
        error: function(error) {
          console.error("Error deleting related comments " + error.code + ": " + error.message);
        }
      });
    },
    error: function(error) {
      console.error("Error finding related comments " + error.code + ": " + error.message);
    }
  });
});