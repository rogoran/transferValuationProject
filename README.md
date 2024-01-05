## Introduction
The value of a football player is hard to estimate. There are several factors that go into evaluating a player; some are quantifiable variables, some are qualitative, and some are even unexplainable. Currently, there is not an established model used for evaluating players. This may be due to the complexity of accurately estimating these, but also because there is not a deterministic answer for the value of a player, or at least for the price. The price that a player is sold for is seldom what is thought to be their value. Therefore, the actual price and valuation of a player must be distinguished in our project. “Beauty is in the eyes of the beholder” is a known idiom and enough reason for us to exclude variables that are not related to the actual player, such as the interested club(s)’s buying power etc, when estimating the value of a player.

Instead, in this project we have attempted to make our own model that can evaluate a player’s value, solely based on their own stats and characteristics.
The model can be tried here, where the user can put in different stats and attributes for the player, and get back what the player’s value should be according to our model:
https://huggingface.co/spaces/Siphh/scalable_project

There is also a monitoring site that predicts random players, comparing the predicted value to the value according to https://www.transfermarkt.com/.
Monitoring link:
https://huggingface.co/spaces/Siphh/scalable_project_monitoring

## Data
The data is collected from Kaggle (https://www.kaggle.com/datasets/davidcariboo/player-scores), and is scraped from the author of the dataset David Cariboo. The data has samples from 2001 - current week. The dataset is updated each week and is therefore dynamic, enabling us to update the model and adding training data. 

The dataset consists of several files, all of which are not used in our project, but are mapped as following
<img width="562" alt="Skärmavbild 2023-12-29 kl  13 36 55" src="https://github.com/rogoran/transferValuationProject/assets/98389590/7b91a5ae-2cb5-4677-9e2f-f599bf7bb028">

## Method
EDA and feature pipeline:
Our goal was to create a table where each row consists of different features that are thought to affect a player’s value, as well as their valuation at the time which is the target. However, the structure of the data looks nothing like this; the files consist of different data and different schemas, and therefore a lot of data engineering and cleaning had to be done. Data was gathered from different tables and mapped together by their respective keys. A lot of aggregating and joining had to be done to get a player's stats for one specific season. The final columns looked as following:
<img width="824" alt="Skärmavbild 2023-12-29 kl  13 37 48" src="https://github.com/rogoran/transferValuationProject/assets/98389590/e4cb0be1-d336-4e88-aae9-5cd6cb5e1b89">

When the final table was done, the process of feature engineering was done to figure out what remaining features to keep for the model. We did an extensive EDA including scatterplots, box plots, pair plots etc, to isolate the features that had predictive power, and those to drop. The columns remaining after the EDA were the following:
<img width="892" alt="Skärmavbild 2023-12-29 kl  13 38 15" src="https://github.com/rogoran/transferValuationProject/assets/98389590/03ce9d42-1791-4ad1-83c3-34a3680116e6">

A full explanation and step-by-step presentation of this can be found in the dataset-analysis-pipeline file.

Except for analysis, the EDA and feature pipeline uploads the final features to Hopsworks. The pipeline is written in such a way that it gathers data from a season of choice and inserts it to the feature group on Hopsworks, therefore it is easy to run on earlier seasons. Currently, only data from the season 22/23 is used, and the pipeline will run automatically, with github actions at the the end of each season (every year) and add new data to the feature group. 


## Training and evaluation pipeline
For the training and evaluation pipeline, we split the data into training and test data and tested several different models to compare their performance. The following was the result of the initial test, where each model had standard hyperparameters:
<img width="592" alt="Skärmavbild 2023-12-29 kl  13 38 46" src="https://github.com/rogoran/transferValuationProject/assets/98389590/40a81f1d-2492-489d-9231-07da0359fab3">

We see that Gradient Boosting regressor produced the best results. Thereafter we applied a grid search to see which parameters give the best result:
<img width="907" alt="Skärmavbild 2023-12-29 kl  13 39 22" src="https://github.com/rogoran/transferValuationProject/assets/98389590/837a409d-a858-491b-a8ec-40bd903c22ed">
As the mean value of the predicted values was 10301209, an RMSE of 8500000 is still very high. Although, for high value players, an error of 8500000 euros is not considered very much, for instance if a player’s true value is 100 000 000 euros, a predicted value that differs around 8 000 000 euro from that value is not very inaccurate. However for smaller values, like 10 000 000, an error of 8 000 000 is significant. 

We kept trying to push the RMSE down by systematically normalizing different columns. By normalizing age, height, and minutes played, we pushed the RMSE down to 6 570 000.

Finally, all the best parameters and columns to normalize were collected into a pipeline solely for training, which is run each year, gathers the data from hopsworks, trains a Gradient Boosting regressor and uploads the model to hopsworks.

The model was then used to create an inference pipeline on hugging face that lets users input their own values for a player’s stats, and get the predicted value of a player with such stats. It was also used for a monitoring pipeline that randomly selects 12 players and evaluates them. This is an example of the monitoring:
<img width="599" alt="Skärmavbild 2023-12-29 kl  13 39 59" src="https://github.com/rogoran/transferValuationProject/assets/98389590/19d171d7-127e-489b-a4b6-3a994dcd0d88">

Even if there is a big difference between the actual and predicted value for most players, there are some reasonably close predictions like the first and last prediction.

## How-to-run
Both the prediction and monitoring app are hosted on huggingface with SDK-versions 4.7.1 and 4.10.0 respectively. The necessary Python libraries are gradio, requests, hopsworks, joblib, pandas, scikit-learn for both huggingface apps. 

The backend pipelines and the frontend app is set to update once every year with Github workflows. The workflows can be run manually. However, if it is run earlier than the new season (new year) it will only retrain the model on the same data used in the already uploaded model. 

In order to run the various pipelines, please download the “requirements.txt” and run “pip install -r requirements.txt” to fetch and install the necessary libraries. Python version 3.10.0 was used for this project but will also work for Python version 3.9.x

