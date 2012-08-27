== Welcome to this Twitter Follower Robot Project


This is a ruby on rails practice project. The goal is to interact with Twitter API using OAuth Authentication.

You can SIGN IN from the link over the top right corner of the page to start playing with it.

Any suggestions/comments/critics are welcomed to binzhu1070@gmail.com

Github Link: Twitter_Oauth_Practice

Use cases include.

    Index Page:
    Authorize and let user sign in with twitter account.
    Display friend list with pagination of 20/page upon user signing in.
    Click on user to mark for unfollowing.
    Click "Marker All" to mark all user in current page.
    Click "Unfollow Selected" button to unfollow selected users.
    Put in search keyword to search for users based on screen name. Will redirect to search result page
    Search Result Page:
    Display a list of users based on user's search
    Same click/mark/mark all function with index page.
    Click "Follow Selected" button to follow selected users.
    Signout from app.
    Signout twitter account.

Gems used:

    oauth-ruby, github link

    A gem made for both server and client implementation. Used to obtain access_token and authorize api calls.
    typhoeus, github link

    A gem to make customized http requests. Used to issue authorized http request to make api calls.

Problems encountered:

    Before using 'oauth-ruby' gem, I wrote a customizable oauth library, but the authorization header string seems to be not correct.
    Not sure what to do after user unfollow a list of friends, maybe make another ajax call to fill the space back. And paging status should be updated too.
    Displaying the current paging status was a pain negotiating over backend and frontend logic, I chose backend login with front helpers.

More thoughts:

    Maybe try again to write a oauth authentication library.
    Take performance more into consideration, specifically pagination algorithm, caching data to reduce request, etc.


Bin Zhu 08-26-2012
