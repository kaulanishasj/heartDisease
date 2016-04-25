#!/usr/bin/env python
#
# Copyright 2007 Google Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
from flask import Flask, request, url_for
app = Flask(__name__)
import webapp2
import os
import jinja2
import logging
import json
import csv
import cgi
from google.appengine.api import users

import httplib2
from apiclient.discovery import build
import urllib


# Note: We don't need to call run() since our application is embedded within
# the App Engine WSGI application server.
# this is used for constructing URLs to google's APIS
from googleapiclient.discovery import build

JINJA_ENVIRONMENT = jinja2.Environment(
    loader=jinja2.FileSystemLoader(os.path.dirname(__file__)),
    extensions=['jinja2.ext.autoescape'],
    autoescape=True)

def get_all_data():    
    # open the data stored in a file called "raw_data.csv"
    try:
        with open("data/raw_data.csv", 'rb') as f:
            read = csv.reader(f)
            response = []
            for row in read:
                #logging.info(row)
                response.append(row)
        #first 4 rows are meta-data
        return response[4:]

    except IOError:
        logging.info("failed to load file")        

#load data for % of americans with heart disease
def get_percent_data():
    try:
        with open("data/hasHeartDisease.csv", 'rb') as f:
            read = csv.reader(f)
            response = []
            for row in read:
                #logging.info(row)
                response.append(row)
        #first 4 rows are meta-data
        return response[4:]

    except IOError:
        logging.info("failed to load file")    

def dataDict(d):
    data = {}
    for row in d:
        state = row[0]
        count = float(row[1])
        data[state] = count
    return data

    
def hd_predict(cp = 1, exang = 0, oldpeak = 0, chol = 200, sex = 0, trestbps = 120, thalach = 110, age = 50):
    result = False
    if cp == 1 or cp == 2 or cp == 3:
        if chol >= 50:
            if age < 56:
                result = False
            else:
                if sex == 0:
                    result = False
                else:
                    if thalach >= 136:
                        if chol < 250:
                            result = False
                        else:
                            result = True
                    else:
                        result = True
        else:
            result = True
    else:
        if exang == 0:
            if oldpeak < 1.7:
                if chol >= 56:
                    if sex == 0:
                        result = False
                    else:
                        if trestbps >= 128:
                            if thalach >= 126:
                                result = False
                            else:
                                result = True
                        else:
                            result = True
                else:
                    result = True
            else:
                result = True
        else:
            result = True
    
    return result
    
    
    
    
def get_data(data):
    #state, male, female
    femaleData = {}
    maleData = {}
    bothData = {}
    femaleTotal = 0
    maleTotal = 0
    bothTotal = 0
    row_count = 0
    femaleAv = 0
    maleAv = 0
    bothAv = 0

    for row in data:
        state = row[0]
        male = float(row[1])
        female = float(row[2])
        both = float(male) + float(female)
        femaleData[state] = female
        maleData[state] = male
        bothData[state] = both 
        femaleTotal += female 
        maleTotal += male
        bothTotal += both
        row_count += 1 

    femaleAv = femaleTotal / row_count
    maleAv = maleTotal / row_count
    bothAv = bothTotal / row_count

    return (femaleData, maleData, bothData, femaleAv, maleAv, bothAv)

    
@app.route('/')
def index():
    template = JINJA_ENVIRONMENT.get_template('templates/home.html')
    data = get_all_data()
    (femaleData, maleData, bothData, femaleAv, maleAv, bothAv) = get_data(data)
    percentData = get_percent_data()
    logging.info(percentData)

    variables = {'bothData':bothData, 'female': femaleData, 'male': maleData, 'both': bothData, 
    'femaleAv': femaleAv, 'maleAv': maleAv, 'bothAv': bothAv, 'percentData': percentData}
    return template.render(variables)




def chunks(l, n):
    for i in range(0, len(l), n):
        yield l[i:i+n]


@app.route('/visual')
def visual():
    with open("data/all_clean_data.csv", "rb") as f:
        reader = csv.reader(f)
        i = reader.next()
        rest = [row for row in reader]

    rows = list(chunks(i, 5))
    
    translators = {'age' : "Age", 'sex': "Sex", 'cp' : "Chest Pain Type", 'trestbps':"Resting Blood Pressure",
                              'chol' : "Serum Cholestoral" , 'fbs' : "Fasting Blood Sugar", 'restecg' : "Resting Electrocardiographic Result", 
                              'thalach' : "Maximum Heart Rate Achieved ", 'exang' : "Exercise Induced Angina", 
                              'oldpeak': "ST Depression Induced By Exercise Relative To Rest", 
                              'htn' : "Hypertensive Heart Disease", 'dig' : "Digitalis During Excercise", 
                              'prop' : "Beta Blocker During Excercise", 'nitr' : "Nitrates During Excercise", 'diuretic' : "Diuretic During Excercise",
                              'thaldur' : "Duration of Exercise Test(mins)" , 
                              'thalrest' : "Resting Heart Rate", 'datasource' : "Source of the Data", 'num' : "Diagnosed with Heart Disease"}

    variables = {'rows':rows, 'translators':translators}
    template = JINJA_ENVIRONMENT.get_template('templates/visualization.html')
    return template.render(variables)



@app.route('/prediction')
def prediction():
    template = JINJA_ENVIRONMENT.get_template('templates/prediction.html')
    return template.render()

@app.route('/data_structure')
def data_storage():
    template = JINJA_ENVIRONMENT.get_template('templates/dataStructure.html')
    return template.render()


@app.route('/source_code')
def source_code():
    template = JINJA_ENVIRONMENT.get_template('templates/sourceCode.html')
    image4 = url_for('static', filename='images/image4.jpg')

    return template.render(image4=image4)

@app.route('/quality')
def quality():
    template = JINJA_ENVIRONMENT.get_template('templates/quality.html')
    datapipeproj1 = url_for('static', filename='images/datapipeproj1.jpg')
    datapipeproj2 = url_for('static', filename='images/datapipeproj2.jpg')
    return template.render(datapipeproj1= datapipeproj1, datapipeproj2 = datapipeproj2)
# Define a route for the default URL, which loads the form

@app.route('/form')
def form():
    css_url = 'css/style.css'
    submit_url = url_for('try1')
    template = JINJA_ENVIRONMENT.get_template('templates/try_new.html')
    return template.render( css_url= css_url , submit_url= submit_url)

@app.route('/try1', methods=['POST'])
def try1():
    template = JINJA_ENVIRONMENT.get_template('templates/predict.html')
    
    age = request.form['age']
    sex = request.form['sex']
    chestpain = request.form['chestpain']
    bp = request.form['bp']
    chol = request.form['chol']
    thalach = request.form['thalach']
    excercise = request.form['excercise']
    oldpeak = request.form['oldpeak']
    
    res = hd_predict(cp = chestpain, exang = excercise, oldpeak = oldpeak, chol = chol, sex = sex, trestbps = bp, thalach = thalach, age = age)
    
    return template.render(chestpain = chestpain, age = age, sex= sex, bp = bp, chol = chol,thalach = thalach, excercise = excercise, oldpeak = oldpeak, res = res)
    
    
    
@app.errorhandler(404)
def page_not_found(e):
    """Return a custom 404 error."""
    return 'Sorry, Nothing at this URL.', 404


@app.errorhandler(500)
def application_error(e):
    """Return a custom 500 error."""
    return 'Sorry, unexpected error: {}'.format(e), 500
