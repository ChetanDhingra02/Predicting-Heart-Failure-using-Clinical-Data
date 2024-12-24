heart_data<-read.csv("/Users/chetandhingra/Downloads/heart_failure_clinical_records_dataset.csv")

> # Count missing values in each column
> missing_counts <- colSums(is.na(heart_data))
> print(missing_counts)
                     age                  anaemia creatinine_phosphokinase                 diabetes        ejection_fraction      high_blood_pressure                platelets         serum_creatinine 
                       0                        0                        0                        0                        0                        0                        0                        0 
            serum_sodium                      sex                  smoking                     time              DEATH_EVENT 
                       0                        0                        0                        0                        0 
> 

# box plot for death event and age
> print(age_boxplot)
> ggplot(heart_data, aes(x = as.factor(DEATH_EVENT), y = age)) +
+   geom_boxplot() +
+   labs(title = "Boxplot of Age by Death Event", 
+        x = "Death Event", 
+        y = "Age") +
+   theme_minimal()

# box plot for death event and eection fraction
> ggplot(heart_data, aes(x = as.factor(DEATH_EVENT), y = ejection_fraction)) +
+   geom_boxplot() +
+   labs(title = "Boxplot of ejection_fraction by Death Event", 
+        x = "Death Event", 
+        y = "ejection_fraction") +
+   theme_minimal()

> # Fit a logistic regression model to detect influential points
> logit_model <- glm(DEATH_EVENT ~ ., data = heart_data, family = binomial)
> 
> # Calculate Cook's Distance to find influential points
> cooksD <- cooks.distance(logit_model)
> 
> # Identify influential points
> influential_points <- which(cooksD > (4 / nrow(heart_data)))
> 
> # Remove influential points
> heart_data_cleaned <- heart_data[-influential_points, ]
> 
> # Check the dataset after removing influential points
> summary(heart_data_cleaned)
      age           anaemia       creatinine_phosphokinase    diabetes      ejection_fraction high_blood_pressure   platelets      serum_creatinine  serum_sodium        sex            smoking      
 Min.   :40.00   Min.   :0.0000   Min.   :  23.0           Min.   :0.0000   Min.   :14.00     Min.   :0.0000      Min.   : 25100   Min.   :0.500    Min.   :116.0   Min.   :0.0000   Min.   :0.0000  
 1st Qu.:51.00   1st Qu.:0.0000   1st Qu.: 115.0           1st Qu.:0.0000   1st Qu.:30.00     1st Qu.:0.0000      1st Qu.:212000   1st Qu.:0.900    1st Qu.:134.0   1st Qu.:0.0000   1st Qu.:0.0000  
 Median :60.00   Median :0.0000   Median : 245.0           Median :0.0000   Median :38.00     Median :0.0000      Median :262000   Median :1.100    Median :137.0   Median :1.0000   Median :0.0000  
 Mean   :60.88   Mean   :0.4226   Mean   : 508.9           Mean   :0.4226   Mean   :38.25     Mean   :0.3736      Mean   :262883   Mean   :1.326    Mean   :136.7   Mean   :0.6528   Mean   :0.3245  
 3rd Qu.:70.00   3rd Qu.:1.0000   3rd Qu.: 582.0           3rd Qu.:1.0000   3rd Qu.:45.00     3rd Qu.:1.0000      3rd Qu.:301000   3rd Qu.:1.300    3rd Qu.:140.0   3rd Qu.:1.0000   3rd Qu.:1.0000  
 Max.   :95.00   Max.   :1.0000   Max.   :7861.0           Max.   :1.0000   Max.   :80.00     Max.   :1.0000      Max.   :850000   Max.   :9.400    Max.   :148.0   Max.   :1.0000   Max.   :1.0000  
      time        DEATH_EVENT    
 Min.   :  4.0   Min.   :0.0000  
 1st Qu.: 73.0   1st Qu.:0.0000  
 Median :115.0   Median :0.0000  
 Mean   :131.2   Mean   :0.2792  
 3rd Qu.:206.0   3rd Qu.:1.0000  
 Max.   :285.0   Max.   :1.0000  
> 
> dim((heart_data_cleaned))
[1] 265  13

# histogram to check Distribution of Serum Creatinine
>  ggplot(heart_data_cleaned, aes(x = serum_creatinine)) +
+    geom_histogram(binwidth = 0.1, fill = "red", color = "black", alpha = 0.7) +
+    labs(title = "Distribution of Serum Creatinine", x = "Serum Creatinine", y = "Frequency") +
+    theme_minimal()

> library(e1071)
> skewness_values <- apply(heart_data_cleaned[, sapply(heart_data_cleaned, is.numeric)], 2, skewness)
> print(skewness_values)
                     age                  anaemia creatinine_phosphokinase                 diabetes        ejection_fraction      high_blood_pressure                platelets         serum_creatinine 
               0.4111616                0.3114341                4.9799750                0.3114341                0.4704630                0.5196851                1.6287452                4.6445290 
            serum_sodium                      sex                  smoking                     time              DEATH_EVENT 
              -0.7688804               -0.6384180                0.7453226                0.1402771                0.9785666 
> # for some variables skewness is high (absolute value > 1), using Box-Cox transformation
> # Box-Cox transformation using the caret package
> pre_proc <- preProcess(heart_data_cleaned[, sapply(heart_data_cleaned, is.numeric)], method = "BoxCox")
> heart_data_transformed <- predict(pre_proc, heart_data_cleaned)
> 
> # Check skewness after transformation
> skewness_after_transformation <- apply(heart_data_transformed[, sapply(heart_data_transformed, is.numeric)], 2, skewness)
> print(skewness_after_transformation)
                     age                  anaemia creatinine_phosphokinase                 diabetes        ejection_fraction      high_blood_pressure                platelets         serum_creatinine 
             -0.03015603               0.31143413               0.34898823               0.31143413               0.03902712               0.51968507               0.27867293               0.03476859 
            serum_sodium                      sex                  smoking                     time              DEATH_EVENT 
             -0.58145139              -0.63841801               0.74532259              -0.25070527               0.97856662 
             
> # Calculate the VIF (Variance Inflation Factor) to check multicollinearity
> vif_model <- vif(lm(DEATH_EVENT ~ ., data = heart_data_cleaned))
> print(vif_model)
                     age                  anaemia creatinine_phosphokinase                 diabetes        ejection_fraction      high_blood_pressure                platelets         serum_creatinine 
                1.114458                 1.076481                 1.041049                 1.072310                 1.072022                 1.089370                 1.062377                 1.117532 
            serum_sodium                      sex                  smoking                     time 
                1.114085                 1.339807                 1.282876                 1.196540 
> 

#check for interaction effects

> logit_model_interaction <- glm(DEATH_EVENT ~ age * ejection_fraction + age * serum_creatinine + ejection_fraction * platelets, 
+                                 data = heart_data_cleaned, family = binomial)
> summary(logit_model_interaction)

Call:
glm(formula = DEATH_EVENT ~ age * ejection_fraction + age * serum_creatinine + 
    ejection_fraction * platelets, family = binomial, data = heart_data_cleaned)

Coefficients:
                              Estimate Std. Error z value Pr(>|z|)  
(Intercept)                  2.795e+00  4.753e+00   0.588   0.5565  
age                         -4.514e-02  7.041e-02  -0.641   0.5214  
ejection_fraction           -2.483e-01  1.231e-01  -2.017   0.0437 *
serum_creatinine            -1.468e-01  1.561e+00  -0.094   0.9251  
platelets                    5.073e-06  7.670e-06   0.661   0.5083  
age:ejection_fraction        2.748e-03  1.688e-03   1.628   0.1036  
age:serum_creatinine         2.237e-02  2.576e-02   0.869   0.3851  
ejection_fraction:platelets -1.469e-07  2.205e-07  -0.666   0.5054  
---
Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1

(Dispersion parameter for binomial family taken to be 1)

    Null deviance: 313.89  on 264  degrees of freedom
Residual deviance: 203.71  on 257  degrees of freedom
AIC: 219.71

Number of Fisher Scoring iterations: 6

> # Split the data into training (80%) and testing (20%) sets
> set.seed(123)
> trainIndex <- createDataPartition(heart_data_cleaned$DEATH_EVENT, p = 0.8, list = FALSE, times = 1)
> train_data <- heart_data_cleaned[trainIndex, ]
> test_data <- heart_data_cleaned[-trainIndex, ]
> 
> # Separate predictors (X) and target variable (y)
> x_train <- train_data[, -which(names(train_data) == "DEATH_EVENT")]
> y_train <- train_data$DEATH_EVENT
> x_test <- test_data[, -which(names(test_data) == "DEATH_EVENT")]
> y_test <- test_data$DEATH_EVENT

> # ===========================
> # 1. Logistic Regression Model
> # ===========================

> summary(logit_model)

Call:
glm(formula = DEATH_EVENT ~ ., family = binomial, data = train_data)

Coefficients:
                           Estimate Std. Error z value Pr(>|z|)    
(Intercept)               3.182e+01  1.798e+01   1.769 0.076831 .  
age                       2.561e-01  8.049e-02   3.182 0.001464 ** 
anaemia                  -1.292e+00  1.130e+00  -1.143 0.253140    
creatinine_phosphokinase  2.060e-03  1.351e-03   1.524 0.127505    
diabetes                 -7.239e-01  9.959e-01  -0.727 0.467274    
ejection_fraction        -3.258e-01  9.132e-02  -3.568 0.000360 ***
high_blood_pressure       5.376e-01  9.786e-01   0.549 0.582757    
platelets                 1.105e-07  6.269e-06   0.018 0.985931    
serum_creatinine          3.580e+00  1.072e+00   3.341 0.000835 ***
serum_sodium             -2.425e-01  1.253e-01  -1.935 0.053014 .  
sex                      -2.097e+00  1.309e+00  -1.602 0.109215    
smoking                   1.030e+00  1.155e+00   0.892 0.372400    
time                     -9.942e-02  2.443e-02  -4.070 4.71e-05 ***
---
Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1

(Dispersion parameter for binomial family taken to be 1)

    Null deviance: 252.61  on 211  degrees of freedom
Residual deviance:  40.25  on 199  degrees of freedom
AIC: 66.25

Number of Fisher Scoring iterations: 10

> # ===========================
> # 2. Lasso Model
> # ===========================

> summary(lasso_model)
           Length Class  Mode     
lambda     88     -none- numeric  
cvm        88     -none- numeric  
cvsd       88     -none- numeric  
cvup       88     -none- numeric  
cvlo       88     -none- numeric  
nzero      88     -none- numeric  
call        5     -none- call     
name        1     -none- character
glmnet.fit 13     lognet list     
lambda.min  1     -none- numeric  
lambda.1se  1     -none- numeric  
index       2     -none- numeric  
> # ===========================
> # 3. Ridge Model
> # ===========================
> summary(ridge_model)
           Length Class  Mode     
lambda     100    -none- numeric  
cvm        100    -none- numeric  
cvsd       100    -none- numeric  
cvup       100    -none- numeric  
cvlo       100    -none- numeric  
nzero      100    -none- numeric  
call         5    -none- call     
name         1    -none- character
glmnet.fit  13    lognet list     
lambda.min   1    -none- numeric  
lambda.1se   1    -none- numeric  
index        2    -none- numeric  

> # ===========================
> # 2. Refined logistic Model
> # ===========================
> summary(refined_logit_model)

Call:
glm(formula = DEATH_EVENT ~ ejection_fraction + serum_creatinine + 
    smoking + time, family = binomial, data = heart_data_cleaned)

Coefficients:
                   Estimate Std. Error z value Pr(>|z|)    
(Intercept)        4.919770   1.377133   3.572 0.000354 ***
ejection_fraction -0.113554   0.027337  -4.154 3.27e-05 ***
serum_creatinine   2.053920   0.502121   4.090 4.30e-05 ***
smoking            0.175971   0.537390   0.327 0.743324    
time              -0.048955   0.007771  -6.300 2.97e-10 ***
---
Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1

(Dispersion parameter for binomial family taken to be 1)

    Null deviance: 313.89  on 264  degrees of freedom
Residual deviance: 103.37  on 260  degrees of freedom
AIC: 113.37

Number of Fisher Scoring iterations: 7

> > # Get predictions for Logistic Regression
> logit_predictions <- predict(logit_model, test_data, type = "response")
> logit_pred_class <- ifelse(logit_predictions > 0.5, 1, 0)
> logit_roc <- roc(y_test, logit_predictions)
Setting levels: control = 0, case = 1
Setting direction: controls < cases

> # Confusion Matrix for Logistic Regression
> logit_cm <- confusionMatrix(as.factor(logit_pred_class), as.factor(y_test))
> print(logit_cm)
Confusion Matrix and Statistics

          Reference
Prediction  0  1
         0 39  4
         1  0 10
                                          
               Accuracy : 0.9245          
                 95% CI : (0.8179, 0.9791)
    No Information Rate : 0.7358          
    P-Value [Acc > NIR] : 0.0005349       
                                          
                  Kappa : 0.7863          
                                          
 Mcnemar's Test P-Value : 0.1336144       
                                          
            Sensitivity : 1.0000          
            Specificity : 0.7143          
         Pos Pred Value : 0.9070          
         Neg Pred Value : 1.0000          
             Prevalence : 0.7358          
         Detection Rate : 0.7358          
   Detection Prevalence : 0.8113          
      Balanced Accuracy : 0.8571          
                                          
       'Positive' Class : 0  
       
>> # Get predictions for LASSO
> lasso_predictions <- predict(lasso_model, newx = x_test, type = "response")
> lasso_pred_class <- ifelse(lasso_predictions > 0.5, 1, 0)
> # Confusion Matrix for LASSO
> lasso_cm <- confusionMatrix(as.factor(lasso_pred_class), as.factor(y_test)) 
> print(lasso_cm)
Confusion Matrix and Statistics

          Reference
Prediction  0  1
         0 39  4
         1  0 10
                                          
               Accuracy : 0.9245          
                 95% CI : (0.8179, 0.9791)
    No Information Rate : 0.7358          
    P-Value [Acc > NIR] : 0.0005349       
                                          
                  Kappa : 0.7863          
                                          
 Mcnemar's Test P-Value : 0.1336144       
                                          
            Sensitivity : 1.0000          
            Specificity : 0.7143          
         Pos Pred Value : 0.9070          
         Neg Pred Value : 1.0000          
             Prevalence : 0.7358          
         Detection Rate : 0.7358          
   Detection Prevalence : 0.8113          
      Balanced Accuracy : 0.8571          
                                          
       'Positive' Class : 0               
                                          
> > # Get predictions for Ridge
> ridge_predictions <- predict(ridge_model, newx = x_test, type = "response")
> ridge_pred_class <- ifelse(ridge_predictions > 0.5, 1, 0)
> # Confusion Matrix for Ridge
> ridge_cm <- confusionMatrix(as.factor(ridge_pred_class), as.factor(y_test))
> print(ridge_cm)
Confusion Matrix and Statistics

          Reference
Prediction  0  1
         0 39  5
         1  0  9
                                          
               Accuracy : 0.9057          
                 95% CI : (0.7934, 0.9687)
    No Information Rate : 0.7358          
    P-Value [Acc > NIR] : 0.002024        
                                          
                  Kappa : 0.726           
                                          
 Mcnemar's Test P-Value : 0.073638        
                                          
            Sensitivity : 1.0000          
            Specificity : 0.6429          
         Pos Pred Value : 0.8864          
         Neg Pred Value : 1.0000          
             Prevalence : 0.7358          
         Detection Rate : 0.7358          
   Detection Prevalence : 0.8302          
      Balanced Accuracy : 0.8214          
                                          
       'Positive' Class : 0  
       
> # Get predictions for Refined Logistic Regression
> logit_predictions_refined <- predict(refined_logit_model, test_data, type = "response")
> logit_pred_class_refined <- ifelse(logit_predictions_refined > 0.5, 1, 0)

> # Confusion Matrix for Refined Logistic Regression
> logit_cm_refined <- confusionMatrix(as.factor(logit_pred_class_refined), as.factor(y_test))
> 
> print(logit_cm_refined)
Confusion Matrix and Statistics

          Reference
Prediction  0  1
         0 38  4
         1  1 10
                                          
               Accuracy : 0.9057          
                 95% CI : (0.7934, 0.9687)
    No Information Rate : 0.7358          
    P-Value [Acc > NIR] : 0.002024        
                                          
                  Kappa : 0.7394          
                                          
 Mcnemar's Test P-Value : 0.371093        
                                          
            Sensitivity : 0.9744          
            Specificity : 0.7143          
         Pos Pred Value : 0.9048          
         Neg Pred Value : 0.9091          
             Prevalence : 0.7358          
         Detection Rate : 0.7170          
   Detection Prevalence : 0.7925          
      Balanced Accuracy : 0.8443          
                                          
       'Positive' Class : 0               
                                        

> # Load necessary library
> library(pROC)
> 
> # =======================
> # Logistic Regression AUC
> # =======================
> logit_predictions <- predict(logit_model, test_data, type = "response")
> logit_roc <- roc(y_test, logit_predictions)  # Using y_test as true labels
Setting levels: control = 0, case = 1
Setting direction: controls < cases
> auc_logit <- auc(logit_roc)
> cat("Logistic Regression AUC:", auc_logit, "\n")
Logistic Regression AUC: 0.989011 
> 
> # =======================
> # LASSO AUC
> # =======================
> lasso_predictions <- predict(lasso_model, newx = as.matrix(x_test), type = "response")
> lasso_roc <- roc(y_test, lasso_predictions)  # Using y_test as true labels
Setting levels: control = 0, case = 1
Setting direction: controls < cases
Warning message:
In roc.default(y_test, lasso_predictions) :
  Deprecated use a matrix as predictor. Unexpected results may be produced, please pass a numeric vector.
> auc_lasso <- auc(lasso_roc)
> cat("LASSO AUC:", auc_lasso, "\n")
LASSO AUC: 0.9871795 
> 
> # =======================
> # Ridge AUC
> # =======================
> ridge_predictions <- predict(ridge_model, newx = as.matrix(x_test), type = "response")
> ridge_roc <- roc(y_test, ridge_predictions)  # Using y_test as true labels
Setting levels: control = 0, case = 1
Setting direction: controls < cases
Warning message:
In roc.default(y_test, ridge_predictions) :
  Deprecated use a matrix as predictor. Unexpected results may be produced, please pass a numeric vector.
> auc_ridge <- auc(ridge_roc)
> cat("Ridge AUC:", auc_ridge, "\n")
Ridge AUC: 0.9871795 
> 
> # =======================
> # Refined Logistic Regression AUC
> # =======================
> logit_predictions_refined <- predict(refined_logit_model, test_data, type = "response")
> logit_roc_refined <- roc(y_test, logit_predictions_refined)  # Using y_test as true labels
Setting levels: control = 0, case = 1
Setting direction: controls < cases
> auc_logit_refined <- auc(logit_roc_refined)
> cat("Refined Logistic Regression AUC:", auc_logit_refined, "\n")
Refined Logistic Regression AUC: 0.9377289 
> 
> 
