class CreateMonthIndexFunction < ActiveRecord::Migration[7.0]
  def change
    execute <<-SQL.squish
      CREATE OR REPLACE FUNCTION month_index(month integer, year integer) RETURNS integer AS $$
        BEGIN
            RETURN month + year * 12;
        END;
        $$ LANGUAGE plpgsql;
    SQL
  end
end
