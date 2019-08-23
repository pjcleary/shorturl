class CreateShortenedurls < ActiveRecord::Migration[5.2]
  def change
    create_table :shortenedurls do |t|
      t.string :longurl
      t.string :shorturlpath

      t.timestamps
    end
  end
end
