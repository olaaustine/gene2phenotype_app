$(document).ready(function(){
  $( ".accordion" ).accordion({
heightStyle: "content",
collapsible: true,
active: false,

  });

  function compare(a,b) {
    return parseInt(a.span.begin) - parseInt(b.span.begin);
  }

  $( ".hide_pubtator_annotations" ).on( "click", function() {
    var div_remove = $(this).parent().find('.tm2');
    div_remove.remove();
    var div_hide = $(this).parent().find('.tm');
    div_hide.hide();
    var show_button = $(this).parent().find('.show_pubtator_annotations');
    show_button.show();
    var hide_button = $(this);
    hide_button.addClass('hide');
  });

  $( ".show_pubtator_annotations" ).on( "click", function() {
    var pmid = $(this).parent().find('.tm_pmid').text();
    var tm_div = $(this).parent().find('.tm');
    var div = tm_div.find('.tm_pubtator');
    var hide_button = $(this).parent().find('.hide_pubtator_annotations');
    var url = 'https://www.ncbi.nlm.nih.gov/CBBresearch/Lu/Demo/RESTful/tmTool.cgi/Gene,Disease,Mutation/' + pmid + '/PubAnnotation?content-type=application/json';
    $.getJSON(url)
      .done(function(data) {
        if (!data.error) {
          var text = data[0].text; 
          text = text.replace(/\\/g, '');
          var text_length = text.length;
          var denotations = data[0].denotations;
          denotations.sort(compare);
          var arrayLength = denotations.length;
          var start = 0;
          var annotated_abstract = '<br>';
          var annotation_types = {};
           
          for (var i = 0; i < arrayLength; i++) {
            var denotation_start = denotations[i].span.begin;
            var denotation_end = denotations[i].span.end;
            var annotation = denotations[i].obj.split(':', 2);
            var annotation_type = annotation[0];
            annotation_types[annotation_type] = 1;
            var annotation_desc = annotation[1];
            var annotation_highlight = 'tm_' + annotation_type;
            var end = denotation_start - 1;
            if (end != -1) {
              var subtext = text.substring(start, end + 1);
              annotated_abstract = annotated_abstract + subtext;
            }
            var subtext = text.substring(denotation_start, denotation_end);
            var html_annotation = "<div class='" + annotation_highlight + "'>" + subtext + "</div>";
            annotated_abstract = annotated_abstract + html_annotation;
            start = denotation_end;            
          }
          if (start < text_length) {
            var subtext = text.substring(start, text_length + 1);
            annotated_abstract = annotated_abstract + subtext;
          }
          tm_div.show();
          var legend = '';
          for (var i in annotation_types) {
            legend = legend + "<span class='tm_" + i + " tm_legend'>" + i + "</span>"; 
          }  
          div.append("<div class='tm2'>" + annotated_abstract + '<br>' + legend + "</div>");
          hide_button.removeClass('hide');
        }
    });
    $(this).hide();
  });

  if ($('#gene_symbol').length > 0) {  
    var gene_symbol = $('#gene_symbol').text();
    $.getJSON('https://rest.ensembl.org/lookup/symbol/homo_sapiens/' + gene_symbol + '?content-type=application/json')
      .done(function(data) {
        if (!data.error) {
          var assembly_name = data.assembly_name; 
          var chrom = data.seq_region_name;
          var start = data.start;
          var end = data.end;
          var strand = data.strand;
          var gene_location = assembly_name + ':' + chrom + ':' + start + '-' + end + ' (' + strand + ')';
          $("#gene_location").append(gene_location);
        }
    });
  }
//    $.ajax({
//      url: "/gene2phenotype/ajax/gene_location",
//      dataType: "json",
//      type: "get",
//      data: {
//        gene_symbol : gene_symbol,
//      },
//      success: function(data, textStatus, jqXHR) {
//        console.log(textStatus);
//        var gene_location = data.gene_location;
//        $("#gene_location").append(gene_location);
//      },
//      error: function(jqXHR, textStatus, errorThrown){
//        console.log(jqXHR);
//        console.log(textStatus);
//        console.log(errorThrown);
//      }
//    });
//  }

  $("#edit_pwd_link").click(function(){
    $("#update_pwd").show();
    $(this).hide();
  });

  $("#cancel_update_pwd_button").click(function(){
    $("#update_pwd").hide();
    $("#edit_pwd_link").show();
  });
 
  $("#select_panel").change(function(){
    var value =  $(this).val(); 
    var img_src = '/gene2phenotype/images/G2P-' + value + '.png';
    $('img[alt="panel_image"]').attr('src', img_src);
  }); 

  $("#query_phenotype_name, #query, #query_gene_name, #query_disease_name" ).click(function(){
    var id = $(this).attr('id');
    $(this).autocomplete({
      source: function(request, response) {
        $.ajax({
          url: "/gene2phenotype/ajax/autocomplete",

          dataType: "json",
          data: {
            term : request.term,
            query_type : id,
          },
          success: function(data, type) {
            items = data;
            response(items);
          },
          error: function(data, type){
            console.log( type);
          }
        });
      },
      minLength: 2,
      select: function(event, ui) {}
    });
  }); 

  $('#ensembl_variants_table').DataTable();
  $('.tm_variants_table').DataTable();

  var index;
  var panels = ["DD", "Cancer", "Ear", "Prenatal"];
  for (index = 0; index < panels.length; ++index) {
    $('#curator_table_' + panels[index]).DataTable();
  }


  $(".show_toggle_view_button").mouseleave(function(){
    $(this).closest('.show_db_content').find('.section_header').css('background-color', 'white');
    $(this).closest('.show_db_content').find('.display_attributes').css('background-color', 'white');
    $(this).closest('.add_GDM').find('.section_header').css('background-color', 'white');
  });

  $(".show_toggle_view_button").mouseenter(function(){
    $(this).closest('.show_db_content').find('.section_header').css('background-color', '#bbdefb');
    $(this).closest('.show_db_content').find('.display_attributes').css('background-color', '#bbdefb');
    $(this).closest('.add_GDM').find('.section_header').css('background-color', '#bbdefb');
  });

  $(".show_add_publication").mouseenter(function(){
    $(this).closest('.show_db_content').find('.section_header').css('background-color', '#bbdefb');
  });

  $(".show_add_publication").mouseleave(function(){
    $(this).closest('.show_db_content').find('.section_header').css('background-color', 'white');
  });

  $(".align_right").mouseenter(function(){
    $(this).prev().css('background-color', '#bbdefb');
  }); 

  $(".align_right").mouseleave(function(){
    $(this).prev().css('background-color', 'white');
  }); 

  $(".align_buttons_left").mouseenter(function(){
    var dev = $(this).closest('.publication_action');
    dev.prev().css('background-color', '#bbdefb');
  }); 

  $(".align_buttons_left").mouseleave(function(){
    var dev = $(this).closest('.publication_action');
    dev.prev().css('background-color', 'white');
  }); 

  $(".header_gene_disease").click(function(){
    $header = $(this);
    $content = $header.next();
    $content.toggle(function() {
      $span = $header.children("span");
      if ($(this).is(":visible")) {
        $($span).removeClass("glyphicon glyphicon-chevron-up");
        $($span).addClass("glyphicon glyphicon-chevron-down");
      } else {
        $($span).removeClass("glyphicon glyphicon-chevron-down");
        $($span).addClass("glyphicon glyphicon-chevron-up");
      }
    });
  });

  $(".button_show_add_comment_phenotype").click(function(){
    $button = $(this);
    $first_parent_div = $button.parent();
    $third_parent_div = $first_parent_div.parent().parent();      
    $next_div = $third_parent_div.next();
    $next_div.show(function(){
      $first_parent_div.hide();
    });   
  });

  $(".discard_add_comment_phenotype").click(function(){
    $button = $(this);
    $third_parent_div = $button.parent().parent().parent();
    $prev_div = $third_parent_div.prev(); 
    $prev_div_child = $prev_div.find('.show_add_comment_phenotype');
    $prev_div_child.show(function(){
      $third_parent_div.hide();
    });  
  });

  $(".edit").click(function(){
    $button = $(this);
    $button_parent = $button.parent();
    $this_content = $button.closest(".show_db_content");
    $edit_content = $this_content.next();
    $edit_content.show(function(){
      $button_parent.hide();
    });
  });

  $(".discard").click(function(){
    $button = $(this);
    $this_content = $button.closest(".show_edit_content");
    $prev_content = $this_content.prev();
    $this_content.hide(function(){
      $prev_content.find('.show_toggle_view_button').show();
    });
  });


  $('.show_add_comment').click(function(){
    $show_content = $(this).parent().find('.add_comment').show();
  });

  $(".show").click(function(){
    $button = $(this);
    $button_parent = $button.parent();
    $this_content = $button.closest(".show_add_comment");
    $show_content = $this_content.parent().parent().next();
    $show_content.show(function(){
      $button_parent.hide();
    });
  });

  $(".discard_add_comment").click(function(){
    $button = $(this);
    $this_content = $button.closest(".add_comment");
    $prev_content = $this_content.prev();
    $prev_div_child = $prev_content.find('.show_add_comment');
    $this_content.hide(function(){
      $prev_div_child.show();
    });
  });

  $(".show_add_publication_button").click(function(){
    $button = $(this);
    $button_parent = $button.parent();
    $this_content = $button.closest(".show_add_publication");
    $show_content = $this_content.next();
    $show_content.show(function(){
      $button_parent.hide();
    });
  });

  $(".discard_add_publication").click(function(){
    $button = $(this);
    $(':input.title[type="text"]').val('');
    $(':input.source[type="text"]').val('');
    $(':input.pmid[type=text]').val('');
    $(".add_publication_feedback").removeClass("alert alert-warning");
    $(".add_publication_feedback").empty();
    $(".next_step_add_publication").addClass("hide_fields");
    $this_content = $button.closest(".add_publication");
    $prev_content = $this_content.prev();
    $this_content.hide(function(){
      $prev_content.show();
    });
  });

  $(".find").click(function(){
    var pmid = $(':input.pmid[type=text]').val();
    $(".add_publication_feedback").empty();
    $(".add_publication_feedback").removeClass("alert alert-danger");
    if (! (!isNaN(parseFloat(pmid)) && isFinite(pmid))) {
      $(".add_publication_feedback").empty();
      $(".add_publication_feedback").append("You entered an invalid PMID.");
      $(".add_publication_feedback").removeClass("alert alert-danger").addClass("alert alert-danger");
    } else {
      $(".next_step_add_publication").removeClass("hide_fields");
      //var europepmcAPI = 'http://www.ebi.ac.uk/europepmc/webservices/rest/search/query=ext_id:' + pmid + '&format=json&callback=?';
      var europepmcAPI = 'https://www.ebi.ac.uk/europepmc/webservices/rest/search/query=ext_id:' + pmid + '%20src:med&format=json';
      var result;      
      var title, journalTitle, journalVolume, pageInfo, pubYear;
      $.getJSON(europepmcAPI).done(function(data) {
        result = data.resultList.result[0];
        if (result) {
          if ('title' in result === true) {
            title = result.title;
          }
          if ('journalTitle' in result === true) {
            journalTitle = result.journalTitle;
          }
          if ('journalVolume' in result === true) {
            journalVolume = result.journalVolume;
          }
          if ('pageInfo' in result === true) {
            pageInfo = result.pageInfo;
          }

          if ('pubYear' in result === true) {
            pubYear = result.pubYear;
          }
          var source_components = [];
          if (journalTitle) {
            source_components.push(journalTitle);
          }       
          if (journalVolume) {
            if (pageInfo || pubYear) {
              source_components.push(journalVolume + ':');
            } else {
              source_components.push(journalVolume);
            }
          }
          if (pageInfo) {
            if (pubYear) {
              source_components.push(pageInfo + ',');
            } else {
              source_components.push(pageInfo);
            }
          }
          if (pubYear) {
            source_components.push(pubYear);
          }
          var source = source_components.join(' ');
          $(':input.title[type="text"]').val(title);
          $(':input.source[type="text"]').val(source);
        } else {
          $(".add_publication_feedback").append("No publication information could be found for your input PMID. You can enter the publication information yourself or contact g2p-help@ebi.ac.uk for help.");
          $(".add_publication_feedback").removeClass("alert alert-warning").addClass("alert alert-warning");
          $(':input.title[type="text"]').val('');
          $(':input.source[type="text"]').val('');
        }
      });

//      $.ajax({
//        url: "/gene2phenotype/ajax/publication",
//        dataType: "json",
//        type: "get",
//        data: {
//          pmid : pmid,
//        },
//        success: function(data, textStatus, jqXHR) {
//          var title = data.title;
//          var source = data.source;
//          if (title && source) {
//            $(':input.title[type="text"]').val(title);
//            $(':input.source[type="text"]').val(source);
//          } else {
//            $(".add_publication_feedback").append("No publication information could be found for your input PMID. You can enter the publication information yourself or contact g2p-help@ebi.ac.uk for help.");
//            $(".add_publication_feedback").removeClass("alert alert-warning").addClass("alert alert-warning");
//          }
//        },
//        error: function(jqXHR, textStatus, errorThrown){
//          console.log(jqXHR);
//          console.log(textStatus);
//          console.log(errorThrown);
//        }
//      });
    }
  });

  $('#add_publication').submit(function(event){
    var pmid = $(':input.pmid[type="text"]').val();
    var title = $(':input.title[type="text"]').val();
    if ((pmid != '') && (!$.isNumeric(pmid))) {
      event.preventDefault();
      $(".add_publication_feedback").empty();
      $(".add_publication_feedback").append("You need to provide a valid PMID (only numbers e.g. 10094187).");
      $(".add_publication_feedback").removeClass("alert alert-danger").addClass("alert alert-danger");
      return 0;
    } 
    if ((pmid == '') && (title == '') ) { 
      event.preventDefault();
      $(".add_publication_feedback").empty();
      $(".add_publication_feedback").append("You need to provide a valid PMID (only numbers e.g 10094187) or a title.");
      $(".add_publication_feedback").removeClass("alert alert-danger").addClass("alert alert-danger");
      return 0;
    } 
    $(".add_publication_feedback").empty();
    $(".add_publication_feedback").removeClass("alert alert-danger");
    return 1;
  });

  $(".confirm").confirm({
    text: "Delete entry?",
    title: "Confirmation required",
    confirm: function(button) {
      var form = button.closest("form");
      form.submit();  
    },
    cancel: function() {
    },
    confirmButton: "Confirm",
    cancelButton: "Discard",
    post: false,
    confirmButtonClass: "btn btn-primary btn-sm",
    cancelButtonClass: "btn btn-primary btn-sm",
    dialogClass: "modal-dialog modal-lg" // Bootstrap classes for large modal 
  });

});
