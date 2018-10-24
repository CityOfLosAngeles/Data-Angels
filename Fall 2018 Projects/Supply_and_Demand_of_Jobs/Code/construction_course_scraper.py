# -*- coding: utf-8 -*-
"""
Created on Sun Oct 21 11:29:23 2018

@author: Adrianna
"""

from selenium import webdriver 
from selenium.webdriver.support.ui import Select
from selenium.webdriver.common.by import By 
from selenium.webdriver.support.ui import WebDriverWait 
from selenium.webdriver.support import expected_conditions as EC 
from selenium.common.exceptions import TimeoutException
from bs4 import BeautifulSoup
import re
import csv

base_url = 'https://mycollege-guest.laccd.edu/psc/classsearchguest/EMPLOYEE/HRMS/c/COMMUNITY_ACCESS.CLASS_SEARCH.GBL'

def find_courses(subject, url=base_url):
    browser = webdriver.Chrome()
    browser.get(url)
    
    try:
        WebDriverWait(browser, 3).until(EC.presence_of_element_located((By.ID, 'CLASS_SRCH_WRK2_SSR_PB_CLASS_SRCH')))
        print ("Search Page is ready!")
    except TimeoutException:
        print ("Loading took too much time!")
        
    #option value = 2188, 2192
#    select = Select(browser.find_element_by_id('CLASS_SRCH_WRK2_STRM$35$'))
#    select.select_by_value('2192')

#    Search page seems to refresh / get reloaded after selecting a term.  Need to wait about 2 seconds   
#    import time
#    time.sleep(2)
    
    editor = browser.find_element_by_id('SSR_CLSRCH_WRK_SUBJECT$0')
    editor.send_keys(subject)
    
    select = Select(browser.find_element_by_id('SSR_CLSRCH_WRK_INCLUDE_CLASS_DAYS$7'))
    select.select_by_value('J') 
    
    browser.find_element_by_id('SSR_CLSRCH_WRK_MON$7').click()
    browser.find_element_by_id('SSR_CLSRCH_WRK_TUES$7').click()
    browser.find_element_by_id('SSR_CLSRCH_WRK_WED$7').click()
    browser.find_element_by_id('SSR_CLSRCH_WRK_THURS$7').click()
    browser.find_element_by_id('SSR_CLSRCH_WRK_FRI$7').click()
    browser.find_element_by_id('SSR_CLSRCH_WRK_SAT$7').click()
    browser.find_element_by_id('SSR_CLSRCH_WRK_SUN$7').click() 
    
    browser.find_element_by_id('CLASS_SRCH_WRK2_SSR_PB_CLASS_SRCH').click()
    
    isPresent = len(browser.find_elements(By.ID, '#ICSave')) > 0
    if (isPresent):
        browser.find_element_by_id('#ICSave').click()
    
    try:
        WebDriverWait(browser, 10).until(EC.presence_of_element_located((By.ID, 'CLASS_SRCH_WRK2_SSR_PB_MODIFY$5$')))
        print ("Result Page is ready!")
        return browser
    except TimeoutException:
        print ("Can't load the result page!  Nothing will get added")
        print (subject + " returns no results")
        return ''
#    finally:
#        browser.close    
    
def parse_courses(subject, url=base_url):
    dataset = []
    result_page = find_courses(subject, url)

    if (result_page == ''):
        return dataset
    else:
        soup_level1=BeautifulSoup(result_page.page_source, 'lxml')
    
    classname = soup_level1.findAll("div", {"id" : re.compile('win0divSSR_CLSRSLT_WRK_GROUPBOX2GP.*')})   
    number_of_classes = (len(classname))
    
    x = 0    
    while (x < number_of_classes):
        course_title = soup_level1.find("div", {"id" : 'win0divSSR_CLSRSLT_WRK_GROUPBOX2GP$'+ str(x)})
        section = soup_level1.find("div", {"id" : 'win0divSSR_CLSRSLT_WRK_GROUPBOX2$' + str(x)})
        
        course_time = section.findAll("div", {"id" : re.compile('win0divMTG_DAYTIME.*')})
        
        course_campus = section.findAll("div", {"id" : re.compile('win0divMTG_ROOM.*')})
        course_term = section.findAll("div", {"id" : re.compile('win0divMTG_TOPIC.*')})
        y = 0
        while (y < len(course_time)):
            course = (course_title.text).replace('\xa0', '')
            mtime = (course_time[y].text).replace('\n', '')
            term = (course_term[y].text).replace('\n', '')
            campus = (course_campus[y].text).replace('\n', '')
            course_data = [course.split('- ')[1], mtime, term, get_campus_name(campus.split('-')[0].strip()), subject]
            dataset.append(course_data)
            y += 1
        x += 1
    
    return dataset

def get_campus_name(campus_short_name):
    if (campus_short_name == 'East'):
        return 'East Los Angeles College'
    elif (campus_short_name == 'Trade'):
        return 'LA Trade-Technical College'
    elif (campus_short_name == 'Pierce'):
        return 'Pierce College'
    elif (campus_short_name == 'West'):
        return 'West Los Angeles College'
    elif (campus_short_name == 'Harbor'):
        return 'Los Angeles Harbor College'
    elif (campus_short_name == 'Southwest'):
        return 'Los Angeles Southwest College'
    elif (campus_short_name == 'Mission'):
        return 'Los Angeles Mission College'
    elif (campus_short_name == 'City'):
        return 'Los Angeles City College'
    else:
        return 'Instructional Television'

def parse_descriptions(subject, url=base_url):
    dataset = []
    result_page = find_courses(subject, url)
    print (result_page)
    if (result_page == ''):
        return dataset
    else:
        soup_level1=BeautifulSoup(result_page.page_source, 'lxml')
    classname = soup_level1.findAll("div", {"id" : re.compile('win0divSSR_CLSRSLT_WRK_GROUPBOX2GP.*')})   
    number_of_classes = (len(classname))

    x = 0
    while (x < number_of_classes):
        course_title = soup_level1.find("div", {"id" : 'win0divSSR_CLSRSLT_WRK_GROUPBOX2GP$'+ str(x)})
        section = soup_level1.find("div", {"id" : 'win0divSSR_CLSRSLT_WRK_GROUPBOX2$' + str(x)})
        
        course_link = section.findAll("a", {"id" : re.compile('MTG_CLASS_NBR.*')})[0]

        result_page.find_element_by_link_text(course_link.text).click()
        try:
            WebDriverWait(result_page, 3).until(EC.presence_of_element_located((By.ID, 'DERIVED_CLSRCH_DESCRLONG')))
            print ("Detail is ready!")
        except TimeoutException:
                print ("Loading took too much time!")
       
        course_description = result_page.find_element_by_id('DERIVED_CLSRCH_DESCRLONG')
        
        result_page.find_element_by_id('CLASS_SRCH_WRK2_SSR_PB_BACK').click()        
        course_detail = [(course_title.text).replace('\xa0', ''), course_description.text, subject]
        print (course_detail)
        dataset.append(course_detail)
        
        try:
            WebDriverWait(result_page, 10).until(EC.presence_of_element_located((By.ID, 'CLASS_SRCH_WRK2_SSR_PB_MODIFY$5$')))
            print ("Back to result!")
        except TimeoutException:
                print ("Loading took too much time!")
        
        x += 1
    
    result_page.close()
    result_page.quit()
    
    return dataset

def save_descriptions(subject, file_name='description'):
    dataset = parse_descriptions(subject)
    with open(file_name +'.csv', 'a') as csvfile:        
        writer = csv.writer(csvfile, delimiter='\t', lineterminator = '\n')
        for data in dataset:
            print (data)
            writer.writerow(data)
    csvfile.close()

def save_courses(subject, file_name='finaloutput'):
    dataset = parse_courses(subject)
    with open(file_name +'.csv', 'a') as csvfile:
        writer = csv.writer(csvfile, lineterminator = '\n')
        for data in dataset:
            print (data)
            writer.writerow(data)
    csvfile.close()

list(map(save_descriptions, ('PLUMBNG', 'WELDG/E','PLUMBNG', 'T & M', 'OPMAINT', 'OPMA AP', 'BLDGCTQ', 'DRAFT', 'ENV', 'IND TEK', 'INT')))
list(map(save_courses, ('PLUMBNG', 'WELDG/E','PLUMBNG', 'T & M', 'OPMAINT', 'OPMA AP', 'BLDGCTQ', 'DRAFT', 'ENV', 'IND TEK', 'INT')))