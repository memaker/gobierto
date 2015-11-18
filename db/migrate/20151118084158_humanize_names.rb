class HumanizeNames < ActiveRecord::Migration
  def change
execute %Q{update "tb_cuentasEconomica" set nombre = 'Gastos en bienes corrientes y servicios' where cdcta = '2' AND tipreig = 'G'}
execute %Q{update "tb_cuentasEconomica" set nombre = 'Gastos financieros' where cdcta = '3' AND tipreig = 'G'}
execute %Q{update "tb_cuentasEconomica" set nombre = 'Transferencias corrientes' where cdcta = '4' AND tipreig = 'G'}
execute %Q{update "tb_cuentasEconomica" set nombre = 'Inversiones reales' where cdcta = '6' AND tipreig = 'G'}
execute %Q{update "tb_cuentasEconomica" set nombre = 'Transferencias de capital' where cdcta = '7' AND tipreig = 'G'}
execute %Q{update "tb_cuentasEconomica" set nombre = 'Activos financieros' where cdcta = '8' AND tipreig = 'G'}
execute %Q{update "tb_cuentasEconomica" set nombre = 'Pasivos financieros' where cdcta = '9' AND tipreig = 'G'}
execute %Q{update "tb_cuentasEconomica" set nombre = 'Impuestos directos' where cdcta = '1' AND tipreig = 'I'}
execute %Q{update "tb_cuentasEconomica" set nombre = 'Impuestos indirectos' where cdcta = '2' AND tipreig = 'I'}
execute %Q{update "tb_cuentasEconomica" set nombre = 'Tasas y otros ingresos' where cdcta = '3' AND tipreig = 'I'}
execute %Q{update "tb_cuentasEconomica" set nombre = 'Transferencias corrientes' where cdcta = '4' AND tipreig = 'I'}
execute %Q{update "tb_cuentasEconomica" set nombre = 'Ingresos patrimoniales' where cdcta = '5' AND tipreig = 'I'}
execute %Q{update "tb_cuentasEconomica" set nombre = 'Enajenación de inversiones reales' where cdcta = '6' AND tipreig = 'I'}
execute %Q{update "tb_cuentasEconomica" set nombre = 'Transferencias de capital' where cdcta = '7' AND tipreig = 'I'}
execute %Q{update "tb_cuentasEconomica" set nombre = 'Activos financieros' where cdcta = '8' AND tipreig = 'I'}
execute %Q{update "tb_cuentasEconomica" set nombre = 'Pasivos financieros' where cdcta = '9' AND tipreig = 'I'}
execute %Q{update "tb_cuentasEconomica" set nombre = 'Gastos de personal' where cdcta = '1' AND tipreig = 'G'}
execute %Q{update "tb_cuentasEconomica" set nombre = 'Fondo de contingencia y otros imprevistos' where cdcta = '5' AND tipreig = 'G'}
execute %Q{update "tb_cuentasProgramas" set nombre = 'Producción de bienes públicos de carácter preferente' where cdfgr = '3'}
execute %Q{update "tb_cuentasProgramas" set nombre = 'Deuda pública' where cdfgr = '0'}
execute %Q{update "tb_cuentasProgramas" set nombre = 'Actuaciones de protección y promoción social' where cdfgr = '2'}
execute %Q{update "tb_cuentasProgramas" set nombre = 'Actuaciones de carácter general' where cdfgr = '9'}
execute %Q{update "tb_cuentasProgramas" set nombre = 'Actuaciones de carácter económico' where cdfgr = '4'}
execute %Q{update "tb_cuentasProgramas" set nombre = 'Servicios públicos básicos' where cdfgr = '1'}
  end
end
