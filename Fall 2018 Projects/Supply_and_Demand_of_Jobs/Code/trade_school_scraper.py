# -*- coding: utf-8 -*-
"""
Created on Wed Oct 24 20:33:49 2018

@author: Adrianna

This script is used to scrape courses on Course Horse (https://coursehorse.com/)
"""

from selenium import webdriver 
from selenium.webdriver.common.by import By 
from selenium.webdriver.support.ui import WebDriverWait 
from selenium.webdriver.support import expected_conditions as EC 
from selenium.common.exceptions import TimeoutException
from bs4 import BeautifulSoup
import re
import csv

base_url = 'https://coursehorse.com/los-angeles/classes/professional/construction'

def find_courses(url=base_url):
    browser = webdriver.Chrome()
    browser.get(url)
    
    try:
        WebDriverWait(browser, 20).until(EC.presence_of_element_located((By.XPATH, "//div[@id='welcome-overlay-window']/a/img")))
        print ("Page finished loading!")
    except TimeoutException:
        print ("Loading took too much time!")
        
    # check for pop up
    isPresent = len(browser.find_elements(By.CLASS_NAME, 'modal-close')) > 0
    if (isPresent):
        browser.find_element(By.XPATH, "//div[@id='welcome-overlay-window']/a/img").click()

    return browser

    
def parse_courses(url=base_url):
    dataset = []
    result_page = find_courses(url)

    if (result_page == ''):
        return dataset
    else:
        soup_level1=BeautifulSoup(result_page.page_source, 'lxml')
           
    while (len(result_page.find_elements(By.CLASS_NAME, 'page-next')) > 0):
        soup_level1=BeautifulSoup(result_page.page_source, 'lxml')
        classname = soup_level1.findAll("div", {"id" : re.compile('js-course-.*')})
        for each_class in classname:
            course_title = each_class.find("h4", {"class" : "title"})
            place = each_class.find("p", {"class": "course-place"})
            course_description = each_class.find("p", {"class": "description"})
            course_detail = [(course_title.text.replace('\n', '')), course_description.text.replace('\n', '').replace('\xa0', ' '), place.text.replace('\n', '').replace('at ', '').split(' -')[0]]
            dataset.append(course_detail)       
        result_page.find_element_by_class_name('page-next').click()
        try:
            WebDriverWait(result_page, 10).until(EC.presence_of_element_located((By.ID, 'filter-results')))
            print ("Found more courses...")
        except TimeoutException:
            print ("Loading took too much time!")
    
    result_page.close()
    result_page.quit()
    return dataset

def save_courses(file_name='output'):
    dataset = parse_courses()
    with open(file_name +'.csv', 'w', encoding="utf-8") as csvfile:
        writer = csv.writer(csvfile, delimiter='\t', lineterminator = '\n')
        for data in dataset:
            print (data)
            writer.writerow(data)
    csvfile.close()

save_courses()