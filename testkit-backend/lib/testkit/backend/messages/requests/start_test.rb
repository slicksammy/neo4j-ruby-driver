module Testkit::Backend::Messages
  module Requests
    class StartTest < Request
      SKIPPED_TESTS = {
        'neo4j.test_direct_driver.TestDirectDriver.test_custom_resolver': 'Does not call resolver for direct connections',
        'neo4j.test_direct_driver.TestDirectDriver.test_multi_db': '???',
        'neo4j.test_direct_driver.TestDirectDriver.test_supports_multi_db': '???',
        'neo4j.test_summary.TestDirectDriver.test_can_obtain_notification_info': '???',
        'neo4j.test_summary.TestDirectDriver.test_can_obtain_plan_info': '???',
        'neo4j.test_summary.TestDirectDriver.test_can_obtain_summary_after_consuming_result': '???',
        'neo4j.test_summary.TestDirectDriver.test_no_notification_info': '???',
        'neo4j.test_summary.TestDirectDriver.test_summary_counters_case_1': '???',
        'stub.iteration.test_iteration_tx_run.TestIterationTxRun.test_nested': 'completely pulls the first query before running the second',
        'stub.retry.test_retry_clustering.TestRetryClustering.test_disconnect_on_commit': 'Keeps retrying on commit despite connection being dropped',
        'stub.session_run_parameters.test_session_run_parameters.TestSessionRunParameters.test_empty_query': 'rejects empty string',
      }.transform_keys(&:to_s)

      SKIPPED_PATTERN = {
        /stub\.routing\.test_routing_v.*\.RoutingV.*\.test_should_fail_on_routing_table_with_no_reader/ => 'needs routing table API support',
        /stub\.routing\.test_routing_v.*\.RoutingV.*\.test_should_fail_when_writing_on_writer_that_returns_database_unavailable/ => 'needs routing table API support',
        /stub\.routing\.test_routing_v.*\.RoutingV.*\.test_should_successfully_get_routing_table$/ => 'needs routing table API support',
        /stub.versions.test_versions.TestProtocolVersions.test_should_reject_server_using_verify_connectivity_bolt_4x./ => 'Skipped because it needs investigation',
      }

      BACKEND_INCOMPLETE = [
        /test_disconnects\.TestDisconnects\.test_disconnect_after_hello/,
        /test_disconnects\.TestDisconnects\.test_disconnect_on_hello/,
        /test_no_routing_v3\.NoRoutingV3\.test_should_accept_noop_during_records_streaming/,
        /test_no_routing_v3\.NoRoutingV3\.test_should_check_multi_db_support/,
        /test_no_routing_v3\.NoRoutingV3\.test_should_error_on_commit_failure_using_tx_commit/,
        /test_no_routing_v3\.NoRoutingV3\.test_should_error_on_database_shutdown_using_tx_commit/,
        /test_no_routing_v3\.NoRoutingV3\.test_should_error_on_database_shutdown_using_tx_run/,
        /test_no_routing_v3\.NoRoutingV3\.test_should_error_on_rollback_failure_using_session_close/,
        /test_no_routing_v3\.NoRoutingV3\.test_should_error_on_rollback_failure_using_tx_close/,
        /test_no_routing_v3\.NoRoutingV3\.test_should_error_on_rollback_failure_using_tx_rollback/,
        /test_no_routing_v3\.NoRoutingV3\.test_should_exclude_routing_context/,
        /test_no_routing_v3\.NoRoutingV3\.test_should_pull_all_when_fetch_is_minus_one_using_driver_configuration/,
        /test_no_routing_v3\.NoRoutingV3\.test_should_read_successfully_using_read_session_run/,
        /test_no_routing_v3\.NoRoutingV3\.test_should_read_successfully_using_write_session_run/,
        /test_no_routing_v3\.NoRoutingV3\.test_should_send_custom_user_agent_using_write_session_run/,
        /test_no_routing_v3\.NoRoutingV4x1\..*/,
        /test_no_routing_v4x1\..*\..*/,
        /test_routing_v.*\.RoutingV.*\.test_should_read_successfully_on_empty_discovery_result_using_session_run/,
        /test_routing_v.*\.RoutingV.*\.test_should_request_rt_from_all_initial_routers_until_successful/,
        /test_routing_v.*\.RoutingV.*\.test_should_revert_to_initial_router_if_known_router_throws_protocol_errors/,
        /test_routing_v.*\.RoutingV.*\.test_should_successfully_check_if_support_for_multi_db_is_available/,
        /test_routing_v.*\.RoutingV.*\.test_should_use_resolver_during_rediscovery_when_existing_routers_fail/,
        /test_versions\.TestProtocolVersions\.test_should_reject_server_using_verify_connectivity_bolt_3x0/,
      ]

      def process
        if SKIPPED_TESTS.key?(testName)
          named_entity("SkipTest", reason: SKIPPED_TESTS[testName])
        elsif reason = SKIPPED_PATTERN.find { |expr, _| testName.match?(expr) }&.last
          named_entity("SkipTest", reason: reason)
        elsif BACKEND_INCOMPLETE.any?(&testName.method(:match?))
          named_entity("SkipTest", reason: 'Backend Incomplete')
        else
          named_entity('RunTest')
        end
      end

      # def process
      #   if BACKEND_INCOMPLETE.any?(&testName.method(:match?))
      #     named_entity('RunTest')
      #   else
      #     named_entity("SkipTest", reason: 'Just testing')
      #   end
      # end

      # def process
      #   named_entity('RunTest')
      # end
    end
  end
end
