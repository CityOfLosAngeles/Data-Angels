# IMPORT LIBRARIES
import matplotlib.pyplot as plt
import pandas
from sklearn.cross_validation import train_test_split
import os

import re
from nltk.corpus import stopwords
# nltk.download('stopwords')                           # Have to run this once!

from sklearn.feature_extraction.text import CountVectorizer

from sklearn.linear_model import LogisticRegression
from sklearn.neighbors import KNeighborsClassifier
from sklearn.svm import SVC
from sklearn.tree import DecisionTreeClassifier
from sklearn.ensemble import RandomForestClassifier, AdaBoostClassifier
from sklearn.metrics import accuracy_score, precision_score, recall_score, roc_auc_score, roc_curve, f1_score

import random
import pickle

os.chdir("C:\Jai\Los Angeles\City of LA Data Work\Twitter Sentiment Analysis")

# GET DATA
Tweet = pandas.read_csv("twitter-airline-sentiment/Tweets.csv")
Tweet.head()
Tweet = Tweet[['airline_sentiment', 'airline', 'text']]

Tweet2 = pandas.read_csv("sentiment140/training.1600000.processed.noemoticon.csv", encoding = "ISO-8859-1", header = None)
Tweet2.columns = ['target', 'ids', 'date', 'flag', 'user', 'text']
Tweet2 = Tweet2[['target', 'text']]

Tweet2.head()

# SAMPLE TWEET2
# Using the full data hits a memory error. So I sample.

# Get indices of rows to sample from "Tweet2"
random.seed(20190707)
indices = random.sample(range(0, len(Tweet2)), 
                        int(len(Tweet2) / 64))

# Get selected rows
Tweet2 = Tweet2.iloc[indices]

# EXPLORATORY ANALYSIS AND PLOTS
Mood_count=Tweet['airline_sentiment'].value_counts()

Index = [1,2,3]
plt.bar(Index,Mood_count)
plt.xticks(Index,['negative','neutral','positive'],rotation=45)
plt.ylabel('Mood Count')
plt.xlabel('Mood')
plt.title('Count of Moods')

Tweet['airline'].value_counts()

def plot_sub_sentiment(Airline):
    df=Tweet[Tweet['airline']==Airline]
    count=df['airline_sentiment'].value_counts()
    Index = [1,2,3]
    plt.bar(Index,count)
    plt.xticks(Index,['negative','neutral','positive'])
    plt.ylabel('Mood Count')
    plt.xlabel('Mood')
    plt.title('Count of Moods of '+Airline)
    
plt.figure(1,figsize=(12, 12))
plt.subplot(231)
plot_sub_sentiment('US Airways')
plt.subplot(232)
plot_sub_sentiment('United')
plt.subplot(233)
plot_sub_sentiment('American')
plt.subplot(234)
plot_sub_sentiment('Southwest')
plt.subplot(235)
plot_sub_sentiment('Delta')
plt.subplot(236)
plot_sub_sentiment('Virgin America')

# PREPROCESS DATA

Tweet = Tweet[['airline_sentiment', 'text']]

def tweet_to_words(raw_tweet):
    letters_only = re.sub("[^a-zA-Z]", " ",raw_tweet) 
    words = letters_only.lower().split()                             
    stops = set(stopwords.words("english"))                  
    meaningful_words = [w for w in words if not w in stops] 
    return( " ".join( meaningful_words ))
    
def clean_tweet_length(raw_tweet):
    letters_only = re.sub("[^a-zA-Z]", " ",raw_tweet) 
    words = letters_only.lower().split()                             
    stops = set(stopwords.words("english"))                  
    meaningful_words = [w for w in words if not w in stops] 
    return(len(meaningful_words)) 
    
Tweet['sentiment']=Tweet['airline_sentiment'].apply(lambda x: 0 if x=='negative' else 1)
Tweet2['sentiment']= Tweet2['target'].apply(lambda x: 0 if x==0 else 1)

Tweet['clean_tweet']=Tweet['text'].apply(lambda x: tweet_to_words(x))
Tweet['Tweet_length']=Tweet['text'].apply(lambda x: clean_tweet_length(x))
train, test = train_test_split(Tweet,test_size=0.2,random_state=42)

Tweet2['clean_tweet']=Tweet2['text'].apply(lambda x: tweet_to_words(x))       # Takes ~8 minutes
Tweet2['Tweet_length']=Tweet2['text'].apply(lambda x: clean_tweet_length(x))  # Takes ~7 minutes
train2, test2 = train_test_split(Tweet2, test_size=0.2, random_state=42)

# Clean up
train = train[['sentiment', 'clean_tweet', 'Tweet_length']]
train2 = train2[['sentiment', 'clean_tweet', 'Tweet_length']]
test = test[['sentiment', 'clean_tweet', 'Tweet_length']]
test2 = test2[['sentiment', 'clean_tweet', 'Tweet_length']]

# Combine
all_train = train.append(train2)
all_test = test.append(test2)

train_clean_tweet = []
for tweet in all_train['clean_tweet']:
    train_clean_tweet.append(tweet)
    
test_clean_tweet = []
for tweet in all_test['clean_tweet']:
    test_clean_tweet.append(tweet)
    
v = CountVectorizer(analyzer = "word")
train_features= v.fit_transform(train_clean_tweet)               # Takes ~1 minute
test_features=v.transform(test_clean_tweet)                    

# MODELING

Classifiers = [
    LogisticRegression(C=0.000000001,solver='liblinear',max_iter=200),
    KNeighborsClassifier(3),
    SVC(kernel="rbf", C=0.025, probability=True),
    DecisionTreeClassifier(),
    RandomForestClassifier(n_estimators=200),
    AdaBoostClassifier()]

del(indices, Tweet, Tweet2, train, train2, test, test2, test_clean_tweet, train_clean_tweet, tweet)
dense_features = train_features.toarray()
dense_test= test_features.toarray()

results = pandas.DataFrame(columns = ['Model', 'Accuracy', 'Precision', 'Recall', 'AUC', 'F1'])
classifier_list = []

for classifier in Classifiers:                # Takes a while
    try:
        fit = classifier.fit(train_features, all_train['sentiment'])
        pred = fit.predict(test_features)
        prob = pandas.DataFrame(fit.predict_proba(test_features))
    except Exception:
        fit = classifier.fit(dense_features, all_train['sentiment'])
        pred = fit.predict(dense_test)
        prob = pandas.DataFrame(fit.predict_proba(test_features))
        
    classifier_list.append(fit)
        
    # Metrics
    accuracy = round(accuracy_score(pred, all_test['sentiment']), 2)
    precision = round(precision_score(pred, all_test['sentiment']), 2)
    recall = round(recall_score(pred, all_test['sentiment']), 2)
    auc = round(roc_auc_score(y_true = all_test['sentiment'], y_score = prob[1]), 2)
    f1 = round(f1_score(pred, all_test['sentiment']), 2)
    
    # ROC plot
    fpr, tpr, threshold = roc_curve(y_true = all_test['sentiment'], y_score = prob[1])
    plt.title(str(classifier.__class__.__name__))
    plt.plot(fpr, tpr)
    
    to_append = pandas.DataFrame({'Model': [classifier.__class__.__name__], 
                      'Accuracy': [accuracy], 
                      'Precision': [precision], 
                      'Recall': [recall], 
                      'AUC': [auc], 
                      'F1': [f1]})
    results = results.append(to_append)
    
    print(classifier.__class__.__name__)
    
results

# RANDOM FOREST MODEL ONLY
# We selected the random forest model.
# This section trains only that model.

Classifiers = [RandomForestClassifier(n_estimators=200)]

del(indices, Tweet, Tweet2, train, train2, test, test2, test_clean_tweet, train_clean_tweet, tweet)

rf_results = pandas.DataFrame(columns = ['Model', 'Accuracy', 'Precision', 'Recall', 'AUC', 'F1'])
rf_object = []

for classifier in Classifiers:                
    try:
        fit = classifier.fit(train_features, all_train['sentiment'])
        pred = fit.predict(test_features)
        prob = pandas.DataFrame(fit.predict_proba(test_features))
    except Exception:
        fit = classifier.fit(dense_features, all_train['sentiment'])
    #    pred = fit.predict(dense_test)
    #    prob = pandas.DataFrame(fit.predict_proba(test_features))
        
    rf_object.append(fit)
        
    # Metrics
    accuracy = round(accuracy_score(pred, all_test['sentiment']), 2)
    precision = round(precision_score(pred, all_test['sentiment']), 2)
    recall = round(recall_score(pred, all_test['sentiment']), 2)
    auc = round(roc_auc_score(y_true = all_test['sentiment'], y_score = prob[1]), 2)
    f1 = round(f1_score(pred, all_test['sentiment']), 2)
    
    to_append = pandas.DataFrame({'Model': [classifier.__class__.__name__], 
                      'Accuracy': [accuracy], 
                      'Precision': [precision], 
                      'Recall': [recall], 
                      'AUC': [auc], 
                      'F1': [f1]})
    rf_results = rf_results.append(to_append)
    
# Save model object
with open('rf_model', 'wb') as f:
    pickle.dump(rf_object[0], f)
    
# PREDICT ON NEW DATA

# Load model object                                                                                                                                                                                                           
with open('rf_model', 'rb') as f:
    rf = pickle.load(f)
    
# Import new data
os.chdir("C:\Jai\Los Angeles\City of LA Data Work\Twitter Sentiment Analysis")
new_data_orig = pandas.read_csv("cleaned_old_tweets.csv")
new_data = new_data_orig[["text"]]

# Cleaning functions
new_data['clean_tweet'] = new_data['text'].apply(lambda x: tweet_to_words(x))
new_data['Tweet_length'] = new_data['text'].apply(lambda x: clean_tweet_length(x))  
new_data = new_data[["clean_tweet", "Tweet_length"]]

new_tweet = []
for tweet in new_data['clean_tweet']:
    new_tweet.append(tweet)

# Must have vocabulary fitted above!
new_features= v.transform(new_tweet)  

# Generate predictions on new data
new_pred = rf.predict(new_features)

new_data_orig['pred'] = pandas.Series(new_pred)
new_data_orig.to_csv("results.csv")

new_data_orig[new_data_orig.term == "gentrification"].pred.value_counts(normalize = True)
new_data_orig[new_data_orig.term == "RentControl"].pred.value_counts(normalize = True)
new_data_orig[new_data_orig.term == "Displacement"].pred.value_counts(normalize = True)
new_data_orig[new_data_orig.term == "OpportunityZone"].pred.value_counts(normalize = True)
new_data_orig[new_data_orig.term == "AffordableHousing"].pred.value_counts(normalize = True)
new_data_orig[new_data_orig.term == "EndHomeless"].pred.value_counts(normalize = True)
new_data_orig[new_data_orig.term == "Migration"].pred.value_counts(normalize = True)
new_data_orig[new_data_orig.term == "MissingMiddle"].pred.value_counts(normalize = True)


