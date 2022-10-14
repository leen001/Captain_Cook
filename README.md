# Captain_Cook
# RecipeAI
 An AI that recommends recipes based on given ingredients
 The algorithm receives an ingredient list and matches those to the recipe database
 The reciped that share the most ingredients are then returned
 At this point the database includes 2000+ recipe: the file recipe_ingrids is relevant for the algorithm but is matched 
 back to the file recipe_details in order to return the recipes

Concept:
The recipe database includes 2000+ recipes that were scraped from allrecipes.com
- recipe_urls includes all the urls of the scraped recipes
- recipe_details holds the necessary recipe information to cook for the user
- recipe_ingrids holds the urls, recipename and the ingrediendts, it is needed for the algorithm to match the input 
- tfidf_encodings is the coding of the recipe_ingrids file - to make the textdata readable the recipe_ingrids had to 
  be encoded to numerical data
- tfidf.pkl is the model that can be trained for further purposes

Required: 
- latest pythonversion

- E.g Download pycharm
- Open the project
- You can make test runs directly by running the file recommendations_system.py

  or you can run the API - run the file rest_api and open the browser on the port 127.0.0.1:5000
  you can now get recommendations by adding ingredients to the url devided by %


- The files in the folder scraping are not needed anymore and You wont be able to run these
  if you would still like to you will have to add the correct paths in those files from your dektop
  it will probably be something like .../github/RecipeAI/... PS: if those files still dont run on the computer from 
  the company - try your private device


Have fun and enjoy!
