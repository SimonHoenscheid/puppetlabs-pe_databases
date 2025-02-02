# Tune PostgreSQL
#
# @summary 
#   Tune PostgreSQL settings 
# 
# @param maintenance_work_mem [String] Increase to improve speed of speed of vacuuming and reindexing (Example "1GB")
# @param work_mem [String] Allows PostgreSQL to do larger in-memory sorts (Default: "4MB")
# @param autovacumn_work_mem [String] Similar to but for maintenance_work_mem autovacuum processes only (Example "256MB")
# @param autovacuum_max_workers [Integer] Maximum number of autovacuum processes to run concurrently (Default: 3)
# 
class pe_databases::postgresql_settings (
  # lint:ignore:140chars
  Float[0,1] $autovacuum_vacuum_scale_factor                    = 0.08,
  Float[0,1] $autovacuum_analyze_scale_factor                   = 0.04,
  Integer    $autovacuum_max_workers                            = max(3, min(8, $facts['processors']['count'] / 3)),
  Integer    $log_autovacuum_min_duration                       = -1,
  Integer    $log_temp_files                                    = -1,
  String     $work_mem                                          = '8MB',
  Integer    $max_connections                                   = 1000,
  Hash       $arbitrary_postgresql_conf_settings                = {},
  Float[0,1] $checkpoint_completion_target                      = 0.9,
  Integer    $checkpoint_segments                               = 128,
  Boolean    $manage_postgresql_service                         = true,
  Boolean    $all_in_one_pe_install                             = true,
  Boolean    $manage_reports_autovacuum_cost_delay              = true,
  Optional[Float[0,1]] $factsets_autovacuum_vacuum_scale_factor = 0.80,
  Optional[Float[0,1]] $reports_autovacuum_vacuum_scale_factor  = 0.01,
  String     $maintenance_work_mem                              = $all_in_one_pe_install ? {
    false => "${facts['memory']['system']['total_bytes'] / 1024 / 1024 / 3}MB",
    true  => "${facts['memory']['system']['total_bytes'] / 1024 / 1024 / 8}MB",
  },
  String     $autovacuum_work_mem                               = $all_in_one_pe_install ? {
    false => "${facts['memory']['system']['total_bytes'] / 1024 / 1024 / 3 / $autovacuum_max_workers}MB",
    true  => "${facts['memory']['system']['total_bytes'] / 1024 / 1024 / 8 / $autovacuum_max_workers}MB",
  },
  String     $psql_version                                      = $pe_databases::psql_version,
  # lint:endignore
) {
  $postgresql_service_resource_name = 'postgresqld'
  $postgresql_service_name          = 'pe-postgresql'
  $notify_postgresql_service        = $manage_postgresql_service ? {
    true    => Service[$postgresql_service_resource_name],
    default => undef,
  }
  $notify_console_services          = $all_in_one_pe_install ? {
    true    => Service['pe-console-services'],
    default => undef,
  }

  if $manage_postgresql_service {
    service { $postgresql_service_resource_name :
      ensure => running,
      name   => $postgresql_service_name,
      enable => true,
      notify => $notify_console_services,
    }
  }

  # The value attribute of postgresql_conf requires a string despite validating a float above.
  # https://tickets.puppetlabs.com/browse/MODULES-2960
  # http://www.postgresql.org/docs/9.4/static/runtime-config-autovacuum.html

  Pe_postgresql_conf {
    ensure => present,
    target => "/opt/puppetlabs/server/data/postgresql/${psql_version}/data/postgresql.conf",
    notify => $notify_postgresql_service,
  }

  pe_postgresql_conf { 'autovacuum_vacuum_scale_factor' :
    value => sprintf('%#.2f', $autovacuum_vacuum_scale_factor),
  }

  pe_postgresql_conf { 'autovacuum_analyze_scale_factor' :
    value => sprintf('%#.2f', $autovacuum_analyze_scale_factor),
  }

  pe_postgresql_conf { 'autovacuum_max_workers' :
    value => String($autovacuum_max_workers),
  }

  pe_postgresql_conf { 'autovacuum_work_mem' :
    value => String($autovacuum_work_mem),
  }

  pe_postgresql_conf { 'log_autovacuum_min_duration' :
    value => String($log_autovacuum_min_duration),
  }

  pe_postgresql_conf { 'log_temp_files' :
    value => String($log_temp_files),
  }

  pe_postgresql_conf { 'maintenance_work_mem' :
    value => String($maintenance_work_mem),
  }

  pe_postgresql_conf { 'work_mem' :
    value => String($work_mem),
  }

  pe_postgresql_conf { 'max_connections' :
    value => String($max_connections),
  }

  pe_postgresql_conf { 'checkpoint_completion_target' :
    value => sprintf('%#.2f', $checkpoint_completion_target),
  }

  $checkpoint_segments_ensure = $psql_version ? {
    '9.4'   => 'present',
    default => 'absent',
  }

  pe_postgresql_conf { 'checkpoint_segments' :
    ensure => $checkpoint_segments_ensure,
    value  => String($checkpoint_segments),
  }

  if !empty($arbitrary_postgresql_conf_settings) {
    $arbitrary_postgresql_conf_settings.each | $key, $value | {
      pe_postgresql_conf { $key :
        value => String($value),
      }
    }
  }
}
