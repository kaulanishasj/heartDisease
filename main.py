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

def dataDict(d):
    data = {}
    for row in d:
        state = row[0]
        count = float(row[1])
        data[state] = count
    return data

def get_data(data):
    #state, male, female
    femaleData = {}
    maleData = {}
    bothData = {}
    for row in data:
        state = row[0]
        male = float(row[1])
        female = float(row[2])
        both = float(male) + float(female)
        femaleData[state] = female
        maleData[state] = male
        bothData[state] = both 
    return (femaleData, maleData, bothData)

    
@app.route('/')
def index():
    template = JINJA_ENVIRONMENT.get_template('templates/home.html')
    image1 = url_for('static', filename='images/image1.jpeg')
    image2 = url_for('static', filename='images/image2.jpg')
    image3 = url_for('static', filename='images/image3.jpg')
    return template.render(image1 = image1, image2 = image2, image3 = image3)


@app.route('/about')
def about():
    template = JINJA_ENVIRONMENT.get_template('templates/about.html')
    return template.render()


@app.route('/visual')
def visual():
    data = get_all_data()
    (femaleData, maleData, bothData) = get_data(data)
    
    variables = {'data':data, 'female': femaleData, 'male': maleData, 'both': bothData}
    template = JINJA_ENVIRONMENT.get_template('templates/visualization.html')
    return template.render(variables)

@app.route('/data_storage')
def visual():
   
    template = JINJA_ENVIRONMENT.get_template('templates/dataStorage.html')
    return template.render(variables)

@app.errorhandler(404)
def page_not_found(e):
    """Return a custom 404 error."""
    return 'Sorry, Nothing at this URL.', 404


@app.errorhandler(500)
def application_error(e):
    """Return a custom 500 error."""
    return 'Sorry, unexpected error: {}'.format(e), 500
