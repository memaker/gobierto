# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20151117073404) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "poblacion_municipal_2014", id: false, force: :cascade do |t|
    t.decimal "codigo",                            precision: 10
    t.string  "nombre",                limit: 255
    t.integer "total"
    t.integer "hombres"
    t.integer "mujeres"
    t.float   "total_functional_2010"
    t.float   "total_functional_2011"
    t.float   "total_functional_2012"
    t.float   "total_functional_2013"
    t.float   "total_functional_2014"
    t.float   "total_functional_2015"
    t.integer "province_id"
    t.integer "autonomous_region_id"
  end

  create_table "tb_cuentasEconomica", id: false, force: :cascade do |t|
    t.string  "tipreig", limit: 1
    t.string  "cdcta",   limit: 6
    t.string  "nombre",  limit: 125
    t.integer "level"
  end

  add_index "tb_cuentasEconomica", ["level"], name: "index_tb_cuentasEconomica_on_level", using: :btree

  create_table "tb_cuentasEconomica_2010", id: false, force: :cascade do |t|
    t.string "tipreig", limit: 1
    t.string "cdcta",   limit: 6
    t.string "nombre",  limit: 125
  end

  create_table "tb_cuentasEconomica_2011", id: false, force: :cascade do |t|
    t.string "tipreig", limit: 1
    t.string "cdcta",   limit: 6
    t.string "nombre",  limit: 125
  end

  create_table "tb_cuentasEconomica_2012", id: false, force: :cascade do |t|
    t.string "tipreig", limit: 1
    t.string "cdcta",   limit: 6
    t.string "nombre",  limit: 125
  end

  create_table "tb_cuentasEconomica_2013", id: false, force: :cascade do |t|
    t.string "tipreig", limit: 1
    t.string "cdcta",   limit: 6
    t.string "nombre",  limit: 125
  end

  create_table "tb_cuentasEconomica_2014", id: false, force: :cascade do |t|
    t.string "tipreig", limit: 1
    t.string "cdcta",   limit: 6
    t.string "nombre",  limit: 125
  end

  create_table "tb_cuentasProgramas", id: false, force: :cascade do |t|
    t.string  "cdfgr",  limit: 6
    t.string  "nombre", limit: 125
    t.integer "level"
  end

  add_index "tb_cuentasProgramas", ["level"], name: "index_tb_cuentasProgramas_on_level", using: :btree

  create_table "tb_cuentasProgramas_2010", id: false, force: :cascade do |t|
    t.string "cdfgr",  limit: 3
    t.string "nombre", limit: 125
  end

  create_table "tb_cuentasProgramas_2011", id: false, force: :cascade do |t|
    t.string "cdfgr",  limit: 3
    t.string "nombre", limit: 125
  end

  create_table "tb_cuentasProgramas_2012", id: false, force: :cascade do |t|
    t.string "cdfgr",  limit: 3
    t.string "nombre", limit: 125
  end

  create_table "tb_cuentasProgramas_2013", id: false, force: :cascade do |t|
    t.string "cdfgr",  limit: 3
    t.string "nombre", limit: 125
  end

  create_table "tb_cuentasProgramas_2014", id: false, force: :cascade do |t|
    t.string "cdfgr",  limit: 3
    t.string "nombre", limit: 125
  end

  create_table "tb_economica", id: false, force: :cascade do |t|
    t.decimal "id",                 precision: 15, scale: 2
    t.decimal "idente",             precision: 15, scale: 2
    t.string  "tipreig",  limit: 1
    t.string  "cdcta",    limit: 6
    t.decimal "importe",            precision: 15, scale: 2
    t.integer "year",     limit: 2
    t.integer "level"
    t.integer "ine_code"
  end

  add_index "tb_economica", ["cdcta"], name: "index_tb_economica_on_cdcta", using: :btree
  add_index "tb_economica", ["id"], name: "index_tb_economica_on_id", using: :btree
  add_index "tb_economica", ["ine_code"], name: "index_tb_economica_on_ine_code", using: :btree
  add_index "tb_economica", ["level"], name: "index_tb_economica_on_level", using: :btree
  add_index "tb_economica", ["tipreig"], name: "index_tb_economica_on_tipreig", using: :btree
  add_index "tb_economica", ["year"], name: "index_tb_economica_on_year", using: :btree

  create_table "tb_economica_2010", id: false, force: :cascade do |t|
    t.decimal "id",                precision: 15, scale: 2
    t.decimal "idente",            precision: 15, scale: 2
    t.string  "tipreig", limit: 1
    t.string  "cdcta",   limit: 6
    t.decimal "importe",           precision: 15, scale: 2
  end

  create_table "tb_economica_2011", id: false, force: :cascade do |t|
    t.decimal "id",                precision: 15, scale: 2
    t.decimal "idente",            precision: 15, scale: 2
    t.string  "tipreig", limit: 1
    t.string  "cdcta",   limit: 6
    t.decimal "importe",           precision: 15, scale: 2
  end

  create_table "tb_economica_2012", id: false, force: :cascade do |t|
    t.decimal "id",                precision: 15, scale: 2
    t.decimal "idente",            precision: 15, scale: 2
    t.string  "tipreig", limit: 1
    t.string  "cdcta",   limit: 6
    t.decimal "importe",           precision: 15, scale: 2
  end

  create_table "tb_economica_2013", id: false, force: :cascade do |t|
    t.decimal "id",                precision: 15, scale: 2
    t.decimal "idente",            precision: 15, scale: 2
    t.string  "tipreig", limit: 1
    t.string  "cdcta",   limit: 6
    t.decimal "importe",           precision: 15, scale: 2
  end

  create_table "tb_economica_2014", id: false, force: :cascade do |t|
    t.decimal "id",                precision: 15, scale: 2
    t.decimal "idente",            precision: 15, scale: 2
    t.string  "tipreig", limit: 1
    t.string  "cdcta",   limit: 6
    t.decimal "importe",           precision: 15, scale: 2
  end

  create_table "tb_economica_2015", id: false, force: :cascade do |t|
    t.decimal "id",                precision: 15, scale: 2
    t.decimal "idente",            precision: 15, scale: 2
    t.string  "tipreig", limit: 1
    t.string  "cdcta",   limit: 6
    t.decimal "importe",           precision: 15, scale: 2
  end

  create_table "tb_funcional", id: false, force: :cascade do |t|
    t.decimal "id",                                    precision: 15, scale: 2
    t.decimal "idente",                                precision: 15, scale: 2
    t.string  "cdcta",                       limit: 6
    t.string  "cdfgr",                       limit: 6
    t.decimal "importe",                               precision: 15, scale: 2
    t.integer "year",                        limit: 2
    t.integer "level"
    t.integer "ine_code"
    t.float   "budget_per_inhabitant"
    t.float   "percentage_total_functional"
  end

  add_index "tb_funcional", ["cdfgr"], name: "index_tb_funcional_on_cdfgr", using: :btree
  add_index "tb_funcional", ["id"], name: "index_tb_funcional_on_id", using: :btree
  add_index "tb_funcional", ["ine_code"], name: "index_tb_funcional_on_ine_code", using: :btree
  add_index "tb_funcional", ["level"], name: "index_tb_funcional_on_level", using: :btree
  add_index "tb_funcional", ["year"], name: "index_tb_funcional_on_year", using: :btree

  create_table "tb_funcional_2010", id: false, force: :cascade do |t|
    t.decimal "id",                precision: 15, scale: 2
    t.decimal "idente",            precision: 15, scale: 2
    t.string  "cdcta",   limit: 6
    t.string  "cdfgr",   limit: 3
    t.decimal "importe",           precision: 15, scale: 2
  end

  create_table "tb_funcional_2011", id: false, force: :cascade do |t|
    t.decimal "id",                precision: 15, scale: 2
    t.decimal "idente",            precision: 15, scale: 2
    t.string  "cdcta",   limit: 6
    t.string  "cdfgr",   limit: 3
    t.decimal "importe",           precision: 15, scale: 2
  end

  create_table "tb_funcional_2012", id: false, force: :cascade do |t|
    t.decimal "id",                precision: 15, scale: 2
    t.decimal "idente",            precision: 15, scale: 2
    t.string  "cdcta",   limit: 6
    t.string  "cdfgr",   limit: 3
    t.decimal "importe",           precision: 15, scale: 2
  end

  create_table "tb_funcional_2013", id: false, force: :cascade do |t|
    t.decimal "id",                precision: 15, scale: 2
    t.decimal "idente",            precision: 15, scale: 2
    t.string  "cdcta",   limit: 6
    t.string  "cdfgr",   limit: 3
    t.decimal "importe",           precision: 15, scale: 2
  end

  create_table "tb_funcional_2014", id: false, force: :cascade do |t|
    t.decimal "id",                precision: 15, scale: 2
    t.decimal "idente",            precision: 15, scale: 2
    t.string  "cdcta",   limit: 6
    t.string  "cdfgr",   limit: 3
    t.decimal "importe",           precision: 15, scale: 2
  end

  create_table "tb_funcional_2015", id: false, force: :cascade do |t|
    t.decimal "id",                precision: 15, scale: 2
    t.decimal "idente",            precision: 15, scale: 2
    t.string  "cdcta",   limit: 6
    t.string  "cdfgr",   limit: 6
    t.decimal "importe",           precision: 15, scale: 2
  end

  create_table "tb_inventario", id: false, force: :cascade do |t|
    t.decimal "id",                    precision: 15, scale: 2
    t.string  "codbdgel",   limit: 10
    t.string  "nombreppal", limit: 70
    t.decimal "idente",                precision: 15, scale: 2
    t.string  "codente",    limit: 10
    t.string  "nombreente", limit: 70
    t.decimal "nsec",                  precision: 15, scale: 2
    t.decimal "poblacion",             precision: 15, scale: 2
    t.string  "estado",     limit: 1
  end

  add_index "tb_inventario", ["codente"], name: "tb_inventario_codente_idx", using: :btree
  add_index "tb_inventario", ["id"], name: "tb_inventario_id_idx", using: :btree

  create_table "tb_inventario_2010", id: false, force: :cascade do |t|
    t.decimal "id",                    precision: 15, scale: 2
    t.string  "codbdgel",   limit: 10
    t.string  "nombreppal", limit: 70
    t.decimal "idente",                precision: 15, scale: 2
    t.string  "codente",    limit: 10
    t.string  "nombreente", limit: 70
    t.decimal "nsec",                  precision: 15, scale: 2
    t.decimal "poblacion",             precision: 15, scale: 2
    t.string  "estado",     limit: 1
  end

  create_table "tb_inventario_2011", id: false, force: :cascade do |t|
    t.decimal "id",                    precision: 15, scale: 2
    t.string  "codbdgel",   limit: 10
    t.string  "nombreppal", limit: 70
    t.decimal "idente",                precision: 15, scale: 2
    t.string  "codente",    limit: 10
    t.string  "nombreente", limit: 70
    t.decimal "nsec",                  precision: 15, scale: 2
    t.decimal "poblacion",             precision: 15, scale: 2
    t.string  "estado",     limit: 1
  end

  create_table "tb_inventario_2012", id: false, force: :cascade do |t|
    t.decimal "id",                    precision: 15, scale: 2
    t.string  "codbdgel",   limit: 10
    t.string  "nombreppal", limit: 70
    t.decimal "idente",                precision: 15, scale: 2
    t.string  "codente",    limit: 10
    t.string  "nombreente", limit: 70
    t.decimal "nsec",                  precision: 15, scale: 2
    t.decimal "poblacion",             precision: 15, scale: 2
    t.string  "estado",     limit: 1
  end

  create_table "tb_inventario_2013", id: false, force: :cascade do |t|
    t.decimal "id",                    precision: 15, scale: 2
    t.string  "codbdgel",   limit: 10
    t.string  "nombreppal", limit: 70
    t.decimal "idente",                precision: 15, scale: 2
    t.string  "codente",    limit: 10
    t.string  "nombreente", limit: 70
    t.decimal "nsec",                  precision: 15, scale: 2
    t.decimal "poblacion",             precision: 15, scale: 2
    t.string  "estado",     limit: 1
  end

  create_table "tb_inventario_2014", id: false, force: :cascade do |t|
    t.decimal "id",                    precision: 15, scale: 2
    t.string  "codbdgel",   limit: 10
    t.string  "nombreppal", limit: 70
    t.decimal "idente",                precision: 15, scale: 2
    t.string  "codente",    limit: 10
    t.string  "nombreente", limit: 70
    t.decimal "nsec",                  precision: 15, scale: 2
    t.decimal "poblacion",             precision: 15, scale: 2
    t.string  "estado",     limit: 1
  end

end
