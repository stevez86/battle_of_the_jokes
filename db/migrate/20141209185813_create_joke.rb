class CreateJoke < ActiveRecord::Migration
  def change

    create_table :jokes do |t|
      t.belongs_to  :category
      t.text        :joke_text
      t.integer     :wins       {default: 0}
      t.integer     :battles    {default: 0}
      t.float       :ranking    {default: 800.0}
      t.boolean     :dead       {default: false}
      t.boolean     :immortal   {default: false}
    end

    create_table :categories do |t|
      t.has_many    :jokes
      t.string      :name
    end

  end
end
