# Tune PostgreSQL table settings
#
# @summary 
#   Tune PostgreSQL table settings
# 
class pe_databases::postgresql_settings::table_settings (
  # lint:ignore:140chars
  Boolean              $manage_reports_autovacuum_cost_delay     = $pe_databases::manage_reports_autovacuum_cost_delay,
  Optional[Float[0,1]] $factsets_autovacuum_vacuum_scale_factor  = $pe_databases::factsets_autovacuum_vacuum_scale_factor,
  Optional[Float[0,1]] $reports_autovacuum_vacuum_scale_factor   = $pe_databases::reports_autovacuum_vacuum_scale_factor,
  Optional[Float[0,1]] $catalogs_autovacuum_vacuum_scale_factor  = $pe_databases::catalogs_autovacuum_vacuum_scale_factor,
  Optional[Float[0,1]] $certnames_autovacuum_vacuum_scale_factor = $pe_databases::certnames_autovacuum_vacuum_scale_factor,
  # lint:endignore
) {
  if $manage_reports_autovacuum_cost_delay {
    pe_databases::set_puppetdb_table_autovacuum_cost_delay_zero { 'reports' : }
  }

  if !empty($factsets_autovacuum_vacuum_scale_factor) {
    pe_databases::set_table_attribute { "Set autovacuum_vacuum_scale_factor=${factsets_autovacuum_vacuum_scale_factor} for factsets" :
      db                    => 'pe-puppetdb',
      table_name            => 'factsets',
      table_attribute       => 'autovacuum_vacuum_scale_factor',
      table_attribute_value => sprintf('%#.2f', $factsets_autovacuum_vacuum_scale_factor),
    }
  }

  if !empty($reports_autovacuum_vacuum_scale_factor) {
    pe_databases::set_table_attribute { "Set autovacuum_vacuum_scale_factor=${reports_autovacuum_vacuum_scale_factor} for reports" :
      db                    => 'pe-puppetdb',
      table_name            => 'reports',
      table_attribute       => 'autovacuum_vacuum_scale_factor',
      table_attribute_value => sprintf('%#.2f', $reports_autovacuum_vacuum_scale_factor),
    }
  }

  if !empty($catalogs_autovacuum_vacuum_scale_factor) {
    pe_databases::set_table_attribute { "Set autovacuum_vacuum_scale_factor=${catalogs_autovacuum_vacuum_scale_factor} for catalogs" :
      db                    => 'pe-puppetdb',
      table_name            => 'catalogs',
      table_attribute       => 'autovacuum_vacuum_scale_factor',
      table_attribute_value => sprintf('%#.2f', $catalogs_autovacuum_vacuum_scale_factor),
    }
  }

  if !empty($certnames_autovacuum_vacuum_scale_factor) {
    pe_databases::set_table_attribute { "Set autovacuum_vacuum_scale_factor=${certnames_autovacuum_vacuum_scale_factor} for certnames" :
      db                    => 'pe-puppetdb',
      table_name            => 'certnames',
      table_attribute       => 'autovacuum_vacuum_scale_factor',
      table_attribute_value => sprintf('%#.2f', $certnames_autovacuum_vacuum_scale_factor),
    }
  }
}
