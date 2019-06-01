# -*- coding: utf-8 -*-
"""
Created on Thu May 30 22:32:36 2019

@author: Adrianna
"""

import tweepy
import csv
import sys

consumer_key= 'xxxx'
consumer_secret= 'xxx'
access_token= 'xxxx'
access_token_secret= 'xxxx'

def search_tweets(query):
    auth = tweepy.OAuthHandler(consumer_key, consumer_secret)
    auth.set_access_token(access_token, access_token_secret)
    api = tweepy.API(auth)
    
    search_term = query
    with open('tweets.csv', 'a', encoding="utf-8",  newline='') as csvfile:
        tweetData = csv.writer(csvfile)
        for tweet in tweepy.Cursor(api.search, q=query + ' -RT', lang = "en", geocode="34.052235,-118.243683,20mi", tweet_mode="extended").items():
            if tweet.coordinates is not None:
                tweetData.writerow([search_term, tweet.created_at, tweet.full_text, tweet.coordinates["coordinates"], tweet.user.screen_name])
            elif tweet.place is not None:
                tweetData.writerow([search_term, tweet.created_at, tweet.full_text, tweet.place.full_name, tweet.user.screen_name])
            else:
                tweetData.writerow([search_term, tweet.created_at, tweet.full_text, tweet.user.location, tweet.user.screen_name])
    csvfile.close()


    


if __name__ == "__main__":
    if len(sys.argv) == 2:
        search_tweets(sys.argv[1])
    else:
        hashtags = ('gentrification','RentControl','DisplacementCrisis','Displacement','OpportunityZone','AffordableHousing','RentBurden','HUDHousingProgram','UnaffordableHousing','EndHomeless','UrbanDisplacement','Migration','MissingMiddle','MiddleClassHousing','WorkforceHousing','HousingCrisis','SkyrocketingRent','HousingShortage','Gentrifying','RentalVacancy','SB50','RentStablization','RentIncrease','LastingAffordability','CommunityLandTrust','HousingIsAHumanRight','HousingForAll','HousingGap','LowIncomeHousing','VoteLandlordsOut','Gentrificationisnotprogress','Gentrify','NoMoreGentrification','EndGentrification','TenantPower','GentrificationSucks','HousingJustice','RentersDayLA','antigentrification','Degentrification','crazyrent','ThingsGentrifiersDo','#rentistoohigh','#rentistoodamnhigh','#rentcontrol','#universalrentcontrol','#makerentfair','#RentersRising','#rentfreeze','#landlordproblems','expropriation','#renting','#endgentrificationnow','Rezoning','Revitalization','Inclusionary','generationpricedout','UrbanDevelopment','rentstrike','changingneighborhood','macarthurpark','crenshawline','BoyleHeights','classsegregation','therowdtla','dtlarow','neighborhoodimprovement','skidrow')
        for hashtag in hashtags:
            #print(hashtag)
            search_tweets(hashtag)
    
