# Author: Harsha Mallajosyula
# Data Scientist
# City of Los Angeles - Mayor's Office
# -*- coding: utf-8 -*-
from selenium import webdriver
from selenium.webdriver.common.action_chains import ActionChains
from selenium.common.exceptions import NoSuchElementException
from selenium.common.exceptions import ElementNotVisibleException
from selenium.webdriver.common.keys import Keys
import csv
import os
import sys
import logging
import random
import time
import codecs
import datetime
from time import strftime
#import re

#setting proxy server
#profile = webdriver.FirefoxProfile()
path = "C:\\Users\\myrtmp235\\Downloads\\chromedriver_win32\\chromedriver.exe"
#profile = webdriver.Chrome(path)
#profile.set_preference("network.proxy.type", 1)
#profile.set_preference("network.proxy.http", "proxy.server.address")
#profile.set_preference("network.proxy.http_port", "port_number")
#profile.update_preferences()
#br = webdriver.Firefox(firefox_profile=profile)
br = webdriver.Chrome(path)
br.implicitly_wait(15) # wait's for the page to get done loading before it does anything with it
br.get('https://www.monster.com/jobs/search/?q=Personal-Care-Aid&where=Los-Angeles__2C-CA&intcid=skr_navigation_nhpso_searchMain&jobid=8e343bf6-0a31-4138-b83a-6481ccc700ca')
time.sleep(15)
br.implicitly_wait(15)
br.switch_to_default_content()

#print ("trying to click")

#br.find_element_by_xpath('//*[@id="SearchResults"]/section[1]/div/div[2]/header/h2/a').click()
#print ("clicked")


time.sleep(10)


SCROLL_PAUSE_TIME = 0.5

#Get scroll height
last_height = br.execute_script("return document.body.scrollHeight")

while True:
    # Scroll down to bottom
    br.execute_script("window.scrollTo(0, document.body.scrollHeight);")

    # Wait to load page
    time.sleep(SCROLL_PAUSE_TIME)

    # Calculate new scroll height and compare with last scroll height
    new_height = br.execute_script("return document.body.scrollHeight")
    if new_height == last_height:
       break
    last_height = new_height

time.sleep(45)

##scrolling back to the top of the page

br.find_element_by_tag_name('body').send_keys(Keys.CONTROL + Keys.HOME)

time.sleep(60)

job_posting_array=[]
company_name_array=[]
location_array=[]
job_description_array = []

for i in range(1,260):
    try:
        
        time.sleep(15)
        job_posting = br.find_element_by_xpath('//*[@id="SearchResults"]/section['+str(i)+']/div/div[2]/header')
        job_posting_1 = job_posting.text#.encode('utf8')
        company_name = br.find_element_by_xpath('//*[@id="SearchResults"]/section['+str(i)+']/div/div[2]/div[1]/a')
        company_name = company_name.text
        location = br.find_element_by_xpath('//*[@id="SearchResults"]/section['+str(i)+']/div/div[2]/div[2]/a')
        location = location.text
        job_posting_array.append(job_posting_1)
        company_name_array.append(company_name)
        location_array.append(location)
        print (job_posting_1)
        time.sleep(5)
        print (company_name)
        time.sleep(3)
        print (location)
        time.sleep(10)
        clickable=br.find_element_by_xpath('//*[@id="SearchResults"]/section['+str(i)+']/div/div[2]/header/h2/a')
       # print (clickable.text)
        actions=ActionChains(br)
        actions.move_to_element(clickable)
        actions.click(clickable)
        actions.perform()
        #br.find_element_by_xpath('//*[@id="SearchResults"]/section[1]/div/div[2]/header/h2/a').click()
        time.sleep(5)
        #i = i+1
        try:
            job_description= br.find_element_by_xpath('//*[@id="JobDescription"]')
            job_description = job_description.text
            job_description_array.append(job_description)
            print (job_description)
            br.back()
            i = i + 1
        except NoSuchElementException:
            br.implicitly_wait(15)
            job_description = "Error loading Job Description"
            job_description_array.append(job_description)
            print ("Error loading Job Description")
            seconds = 5 + (random.random()*5)
            time.sleep(seconds)
            br.back()
            i = i+1
    except NoSuchElementException:
        br.implicitly_wait(15)
        job_posting_1="Error loading"
        company_name="Error loading"
        location="Error loading"
        job_description="Error loading"
        job_posting_array.append(job_posting_1)
        company_name_array.append(company_name)
        location_array.append(location)
        job_description_array.append(job_description)
        print ("Error loading page")
        seconds = 5 + (random.random()*5)
        time.sleep(seconds)
        i = i+1
        #br.back();
    except ElementNotVisibleException:
        br.implicitly_wait(15)
        seconds = 10 + (random.random()*5)
        time.sleep(seconds)
        break

br.quit()


import pandas as pd
data=pd.DataFrame(data=[job_posting_array,company_name_array,location_array,job_description_array]).transpose()
data.to_csv(strftime('Monster_LA_Personal_care_aide_Scraped_Data_%H_%M_%m_%d_%Y.csv'))



