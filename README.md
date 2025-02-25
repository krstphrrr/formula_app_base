# formula_app_base
## todo 

- [x] inventory feature has the same general structure as the ingredients table 
    - inventory table fields: id, ingredient_id, inventory_amount, acquisition_date, personal_notes, cost_per_gram, foreign key to ingredients table
    - ingredients table fields: id, name, cas_number, category (type), description, pyramid_place, substantivity, boiling point, vapor_pressure, molecular_weight, synonyms
            - cas_number can be null for mixtures with undisclosed ingredients
    - name on inventory can be chosen. (using ingredient_synonyms table)

- [ ] solve how to populate inventory 
    - indirect: as you add ingredients in a formula (on formula_ingredients), you check a box. any values from fields that that can  be transported from ingredients table will appear in inventory populated. 
    - direct: you add an ingredient on inventory page. 
        - there must be a dialog that allows you to stringsearch, if it's unavailable you get the option to add new entry. 
        - all fields should be nullable except name. id autogen
        - new entry adds  to both tables: inventory, ingredients. 
        - for now: ingredients table additions are not removable (maybe delete for both prompt on inventory row delete?)

- [ ] formula_ingredients possible adds pulls from ingredients
    - row save would give you the option to add.

- [ ] fix broken sql logic on formula_ingredient pulls: ifra category_0 does not exist. 

