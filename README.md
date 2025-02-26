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
        - [x] all fields should be nullable except name. id autogen
        - new entry adds  to both tables: inventory, ingredients. 
        - for now: ingredients table additions are not removable (maybe delete for both prompt on inventory row delete?)

## todos formula-ingredients
- [x] formula_ingredients possible adds pulls from ingredients
- [ ] row save would give you the option to add. needs ingredient_list to plug into inventory_list; should a transition happen between them? unique check on inventory_list? check behind the scenes if this ingredient already exists in inventory, if so, grey-out checkbox 

- [x] fix broken sql logic on formula_ingredient pulls: ifra category_0 does not exist. 

## todos - inventory - list

- [ ] alter or add a list item widget custom made for the inventory. the other ones may be using fields that are not available on the inventory table

- [ ] adding an inventory item on the inventory list page: 
    - dialog: accord or ingredient? 
    - if  accord, straight to inventory_edit with relevant foreignkeys
    - if  ingredient, lower search pane pops up  and let's the user filter. selecting will use that ingredient_id to populate the next inventory_edit page
