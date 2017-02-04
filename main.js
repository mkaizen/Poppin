
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

Parse.Cloud.define("sendPushToUser", function(request, response) {
  var senderUser = request.user;
  var recipientUserId = request.params.recipientId;
  var message = request.params.message;

  // Validate that the sender is allowed to send to the recipient.
  // For example each user has an array of objectIds of friends
  if (senderUser.get("friendIds").indexOf(recipientUserId) === -1) {
    response.error("The recipient is not the sender's friend, cannot send push.");
  }

  // Validate the message text.
  // For example make sure it is under 140 characters
  if (message.length > 140) {
  // Truncate and add a ...
    message = message.substring(0, 137) + "...";
  }

  // Send the push.
  // Find devices associated with the recipient user
  var recipientUser = new Parse.User();
  recipientUser.id = recipientUserId;
  var pushQuery = new Parse.Query(Parse.Installation);
  pushQuery.equalTo("user", recipientUser);
 
  // Send the push notification to results of the query
  Parse.Push.send({
    where: pushQuery,
    data: {
      alert: message
    }
  }).then(function() {
      response.success("Push was sent successfully.")
  }, function(error) {
      response.error("Push failed to send with error: " + error.message);
  });
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
