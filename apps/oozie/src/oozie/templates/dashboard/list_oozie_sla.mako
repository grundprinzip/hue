## Licensed to Cloudera, Inc. under one
## or more contributor license agreements.  See the NOTICE file
## distributed with this work for additional information
## regarding copyright ownership.  Cloudera, Inc. licenses this file
## to you under the Apache License, Version 2.0 (the
## "License"); you may not use this file except in compliance
## with the License.  You may obtain a copy of the License at
##
##     http://www.apache.org/licenses/LICENSE-2.0
##
## Unless required by applicable law or agreed to in writing, software
## distributed under the License is distributed on an "AS IS" BASIS,
## WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
## See the License for the specific language governing permissions and
## limitations under the License.

<%!
  from desktop.views import commonheader, commonfooter
  from django.utils.translation import ugettext as _
%>

<%namespace name="layout" file="../navigation-bar.mako" />
<%namespace name="utils" file="../utils.inc.mako" />

${ commonheader(_("SLA"), "sla", user) | n,unicode }
${ layout.menubar(section='sla', dashboard=True) }

<style type="text/css">
  .label-with-margin {
    margin-right: 20px;
  }

  .checkbox {
    margin-bottom: 2px !important;
  }

  input[type='checkbox'] {
    margin-right: 5px !important;
    margin-top: 3px;
  }

  th {
    vertical-align: middle !important;
  }

  #yAxisLabel {
    -webkit-transform: rotate(270deg);
    -moz-transform: rotate(270deg);
    -o-transform: rotate(270deg);
    writing-mode: lr-tb;
    margin-left: -110px;
    margin-top: 130px;
    position: absolute;
  }

</style>

<div class="container-fluid">
  <div class="card card-small">
    <h1 class="card-heading simple">
    <div class="pull-left" style="margin-right: 20px;margin-top: 2px">${_('Search')}</div>
    <form class="form-inline" id="searchForm" method="GET" action="." style="margin-bottom: 4px">
      <label>
        ${_('Name or Id')}
        <input type="text" name="job_name" class="searchFilter input-xlarge search-query" placeholder="${_('Job Name or Id (required)')}">
      </label>
      <span style="padding-left:25px">
        <label class="label-with-margin">
          ${ _('Start') }
          <input type="text" name="start_0" class="input-small date" value="" placeholder="${_('Date in GMT')}"  data-bind="enable: useDates">
          <input type="text" name="start_1" class="input-small time" value="" data-bind="enable: useDates">
        </label>
        <label>
          ${ _('End') }
          <input type="text" name="end_0" class="input-small date" value="" placeholder="${_('Date in GMT')}" data-bind="enable: useDates">
          <input type="text" name="end_1" class="input-small time" value="" data-bind="enable: useDates">
        </label>
      </span>
      <label class="checkbox label-with-margin">
        <input type="checkbox" name="useDates" class="searchFilter" data-bind="checked: useDates, click: performSearch()">
        ${ _('Date filter') }
      </label>
    </form>
    </h1>
    <div class="card-body">
      <p>
        <div class="loader hide" style="text-align: center;margin-top: 20px">
          <!--[if lte IE 9]>
              <img src="/static/art/spinner-big.gif" />
          <![endif]-->
          <!--[if !IE]> -->
            <i class="fa fa-spinner fa-spin" style="font-size: 60px; color: #DDD"></i>
          <!-- <![endif]-->
        </div>

        <div class="search-something center empty-wrapper">
          <i class="fa fa-search"></i>
          <h1>${_('Use the form above to search for SLAs.')}</h1>
          <br/>
        </div>

        <div class="no-results center empty-wrapper hide">
          <i class="fa fa-frown-o"></i>
          <h1>${_('The server returned no results.')}</h1>
          <br/>
        </div>

        <div class="results hide">
          <ul class="nav nav-tabs">
            <li class="active"><a href="#slaListTab" data-toggle="tab">${ _('List') }</a></li>
            <li><a href="#chartTab" data-toggle="tab">${ _('Chart') }</a></li>
          </ul>

          <div class="tab-content" style="padding-bottom:200px">
            <div class="tab-pane active" id="slaListTab">
              <div class="tabbable">
                <div class="tab-content">
                  <table id="slaTable" class="table table-striped table-condensed">
                    <thead>
                      <th>${_('Status')}</th>
                      <th>${_('Name')}</th>
                      <th>${_('Type')}</th>
                      <th>${_('ID')}</th>
                      <th>${_('Nominal Time')}</th>
                      <th>${_('Expected Start')}</th>
                      <th>${_('Actual Start')}</th>
                      <th>${_('Expected End')}</th>
                      <th>${_('Actual End')}</th>
                      <th>${_('Expected Duration')}</th>
                      <th>${_('Actual Duration')}</th>
                      <th>${_('Job Status')}</th>
                      <th>${_('User')}</th>
                      <th>${_('Last Modified')}</th>
                    </thead>
                    <tbody>
                    </tbody>
                  </table>
                </div>
              </div>

            </div>

            <div class="tab-pane" id="chartTab" style="padding-left: 20px">
              <div id="yAxisLabel" class="hide">${_('Time since Nominal Time in min')}</div>
              <div id="slaChart"></div>
            </div>
          </div>
        </div>
      </p>
    </div>
  </div>
</div>

<script src="/oozie/static/js/bundles.utils.js" type="text/javascript" charset="utf-8"></script>
<script src="/oozie/static/js/sla.utils.js" type="text/javascript" charset="utf-8"></script>

<script src="/static/ext/js/knockout-min.js" type="text/javascript" charset="utf-8"></script>

<script src="/static/ext/js/jquery/plugins/jquery.flot.min.js" type="text/javascript" charset="utf-8"></script>
<script src="/static/ext/js/jquery/plugins/jquery.flot.selection.min.js" type="text/javascript" charset="utf-8"></script>
<script src="/static/ext/js/jquery/plugins/jquery.flot.time.min.js" type="text/javascript" charset="utf-8"></script>
<script src="/static/js/jquery.blueprint.js"></script>

<script type="text/javascript" charset="utf-8">

  function performSearch(id) {
    if ((id != null || $("input[name='job_name']").val().trim()) != "" && slaTable) {
      window.location.hash = (id != null ? id : $("input[name='job_name']").val().trim());
      $(".results").addClass("hide");
      $(".loader").removeClass("hide");
      $(".search-something").addClass("hide");
      var IN_DATETIME_FORMAT = "MM/DD/YYYY hh:mm A";
      var OUT_DATETIME_FORMAT = "YYYY-MM-DD[T]HH:mm[Z]";
      var _postObj = {
        "job_name": id != null ? id : $("input[name='job_name']").val()
      };

      if (window.viewModel.useDates()) {
        _postObj.useDates = true;
      }
      if ($("input[name='start_0']").val() != "" && $("input[name='start_1']").val() != "") {
        _postObj.start = moment($("input[name='start_0']").val() + " " + $("input[name='start_1']").val(), IN_DATETIME_FORMAT).format(OUT_DATETIME_FORMAT);
      }
      if ($("input[name='end_0']").val() != "" && $("input[name='end_1']").val() != "") {
        _postObj.end = moment($("input[name='end_0']").val() + " " + $("input[name='end_1']").val(), IN_DATETIME_FORMAT).format(OUT_DATETIME_FORMAT)
      }

      $.post("${ url('oozie:list_oozie_sla') }?format=json", _postObj, function (data) {
        $(".loader").addClass("hide");
        slaTable.fnClearTable();
        if (data['oozie_slas'] && data['oozie_slas'].length > 0) {
          $(".no-results").addClass("hide");
          $(".results").removeClass("hide");
          for (var i = 0; i < data['oozie_slas'].length; i++) {
            slaTable.fnAddData(getSLArow(data['oozie_slas'][i]));
          }
        }
        else {
          $(".results").addClass("hide");
          $(".no-results").removeClass("hide");
        }
      });
    }
  }

  var CHART_LABELS = {
    NOMINAL_TIME: "${_('Nominal Time')}",
    EXPECTED_START: "${_('Expected Start')}",
    ACTUAL_START: "${_('Actual Start')}",
    EXPECTED_END: "${_('Expected End')}",
    ACTUAL_END: "${_('Actual End')}",
    TOOLTIP_ADDON: "${_('click for more details')}"
  }

  var slaTable;

  $(document).ready(function () {
    var ViewModel = function () {
      var self = this;

      self.useDates = ko.observable(false);
    };

    window.viewModel = new ViewModel([]);
    ko.applyBindings(window.viewModel);


    $("a[data-row-selector='true']").jHueRowSelector();

    $("*[rel=tooltip]").tooltip();

    $("input[name='start_0']").val(moment().subtract('days', 7).format("MM/DD/YYYY"));
    $("input[name='start_1']").val(moment().subtract('days', 7).format("hh:mm A"));
    $("input[name='end_0']").val(moment().add('days', 1).format("MM/DD/YYYY"));
    $("input[name='end_1']").val(moment().add('days', 1).format("hh:mm A"));


    $.getJSON("${url('oozie:list_oozie_workflows')}?format=json&justsla=true", function (data) {
      var _autocomplete = [];
      $(data).each(function (iWf, item) {
        _autocomplete.push(item.id);
      });
      $("input[name='job_name']").typeahead({
        source: _autocomplete,
        updater: function (item) {
          performSearch(item);
          return item;
        }
      });
    });

    $("input[name='job_name']").on("keydown", function (e) {
      if (e.keyCode == 13) {
        performSearch();
      }
    });

    slaTable = $("#slaTable").dataTable({
      "bPaginate": false,
      "bLengthChange": false,
      "bInfo": false,
      "bAutoWidth": false,
      "oLanguage": {
        "sEmptyTable": "${_('No data available')}",
        "sZeroRecords": "${_('No matching records')}"
      },
      "aaSorting":[
        [4, "desc"]
      ],
      "fnDrawCallback": function (oSettings) {
        $("a[data-row-selector='true']").jHueRowSelector();
      }
    });

    $(".dataTables_wrapper").css("min-height", "0");
    $(".dataTables_filter").hide();

    $("a[data-toggle='tab']").on("shown", function (e) {
      if ($(e.target).attr("href") == "#chartTab") {
        window.setTimeout(function () {
          updateSLAChart(slaTable, CHART_LABELS);
        }, 300)
      }
    });

    if (window.location.hash != "") {
      $("input[name='job_name']").val(window.location.hash.substr(1));
      performSearch(window.location.hash.substr(1));
    }
  });
</script>

${ utils.decorate_datetime_fields() }

<script type="text/javascript" charset="utf-8">
  $(document).ready(function () {
    $("input[name='start_0']").parent().datepicker().on("changeDate", function () {
      performSearch();
    });

    $("input[name='end_0']").parent().datepicker().on("changeDate", function () {
      performSearch();
    });
    $("input[name='start_1']").on("change", function (e) {
      // the timepicker plugin doesn't have a change event handler
      // so we need to wait a bit to handle in with the default field event
      window.setTimeout(function () {
        performSearch();
      }, 200);
    });

    $("input[name='end_1']").on("change", function () {
      window.setTimeout(function () {
        performSearch();
      }, 200);
    });
  });
</script>

${ commonfooter(messages) | n,unicode }
