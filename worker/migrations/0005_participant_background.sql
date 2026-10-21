-- Both surveys use the same database. Apply this file once in total.
ALTER TABLE responses ADD COLUMN background TEXT;
ALTER TABLE responses ADD COLUMN highest_degree TEXT;
