TwitterClient
=============

A simple twitter client sample that uses Restkit and Social_Framework

## How To Get Started
- Download the TwitterClient and open up the TwitterClient.xcworkspace
- Make sure you have setup a twitter account on your device/simulator
- Build and Run

## How it Works
This twitter client works with [Restkit](https://github.com/RestKit/RestKit) (installed with [Cocoapods](http://cocoapods.org)) and the [Social Framework](https://developer.apple.com/library/ios/documentation/Social/Reference/Social_Framework/_index.html). The request url is extracted from an SLRquest and passed to a RKManagedObjectRequestOperation which initiates the request and the response is mapped to coredata objects.

The initial viewcontroller fetches the twitter account stored with the ACAccountStore and displays the username on a tableView.

Selecting an Account from the tableView pushes a second viewcontroller that fetches the timeline for the user and displays the tweets in a collection view.

There is also a "Tweet" right button item on the TimeLineViewController which presents the SLComposeViewController.
