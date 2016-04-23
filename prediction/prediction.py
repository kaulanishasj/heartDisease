# -*- coding: utf-8 -*-
"""
Created on Sat Apr 16 09:02:18 2016

@author: Susrutha
@decision tree program
"""


""" 
Function that takes the following values and predicts whether the person
is at risk of suffering from heart disease
1. Chest pain (cp) - type 1 (4 types possible)
        -- Value 1: typical angina
        -- Value 2: atypical angina
        -- Value 3: non-anginal pain
        -- Value 4: asymptomatic
2. Exercise induced Angina (exang) - default = No (binary yes/no)
3. ST Depression induced by exercise (oldpeak) - default = 0
4. Cholestrol - default = 200
5. Sex - default male
6. Resting Blood Pressure (trestbps) - default(systolic) = 120
7. Maximum Heart Rate - (thalach) default = 110
8. Age - default = 50
"""
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
                
print hd_predict()
 







#from sklearn import tree
##from sklearn.externals.six import StringIO  
##import pydot
##import os
#
#
#""" Read in data as list of lists """
#file_name = "train_data.csv"
#f = open(file_name, 'r')
#headers = f.readline().strip('\r\n').split(',')
#train_data = []
#train_target = []
#for line in f:
#    row = line.strip('\r\n').split(',')
#    train_data.append(row[:len(row)-2])
#    train_target.append(row[-1])
#f.close()
#
#file_name = "testing_data.csv"
#f = open(file_name, 'r')
#test_headers = f.readline().strip('\r\n').split(',')
#test_data = []
#test_target = []
#for line in f:
#    row = line.strip('\r\n').split(',')
#    test_data.append(row[:len(row)-2])
#    test_target.append(row[-1])
#f.close()
#
#
#
#
#
#dtree = tree.DecisionTreeClassifier()
#dtree = dtree.fit(train_data, train_target)
#
##cross_val_score(dtree, train_data, train_target, cv=10)
#print dtree.score(test_data, test_target)
#
##dot_data = StringIO()
##tree.export_graphviz(dtree, out_file=dot_data) 
##graph = pydot.graph_from_dot_data(dot_data.getvalue()) 
##graph.write_pdf("dtree.pdf") 
#
# 
##with open("C:/Users/Susrutha/Desktop/CMU\Spring 2016/Data Pipeline/Project/dtree.dot", 'w') as f:
##    f = tree.export_graphviz(dtree, out_file=f)
##os.unlink('C:/Users/Susrutha/Desktop/CMU\Spring 2016/Data Pipeline/Project/dtree.dot')
# 
# 
# 

 
 
 
 
 
 
 
 
 
 
 
 
 
 
 


    
