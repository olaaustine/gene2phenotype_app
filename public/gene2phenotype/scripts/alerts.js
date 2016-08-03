$(document).ready(function(){
  $('.submit_form').submit(function(event){
    var email = $('.submit_form').find('input[name="email"]').val();
    var password = $('.submit_form').find('input[name="password"]').val();
    if (email == '') {
      event.preventDefault();
      $(".alert").empty();
      $(".alert").append("Email field is empty. You need to enter your email address.");
      $(".alert").removeClass("alert alert-danger").addClass("alert alert-danger");
      return 0;
    }
    if (password == '') {
      event.preventDefault();
      $(".alert").empty();
      $(".alert").append("Password field is empty. You need to enter your password.");
      $(".alert").removeClass("alert alert-danger").addClass("alert alert-danger");
      return 0;
    }
    return 1;
  });
  $('#reset_pwd_form').submit(function(event){
    var new_pwd = $('#reset_pwd_form').find('input[name="new_password"]').val();
    var retyped_pwd = $('#reset_pwd_form').find('input[name="retyped_password"]').val();
    if (new_pwd == '') {
      event.preventDefault();
      $(".alert").empty();
      $(".alert").append("New password field is empty. You need to enter a new password.");
      $(".alert").removeClass("alert alert-danger").addClass("alert alert-danger");
      return 0;
    }
    if (retyped_pwd == '') {
      event.preventDefault();
      $(".alert").empty();
      $(".alert").append("Retype password field is empty. You need to retype your new password.");
      $(".alert").removeClass("alert alert-danger").addClass("alert alert-danger");
      return 0;
    }
    if (new_pwd != retyped_pwd) {
      event.preventDefault();
      $(".alert").empty();
      $(".alert").append("Passwords don't match. Please ensure retyped password matches your new password.");
      $(".alert").removeClass("alert alert-danger").addClass("alert alert-danger");
      return 0;
    }

    return 1;
  });

  $('#update_pwd_form').submit(function(event){
    var current_pwd = $('#update_pwd_form').find('input[name="current_password"]').val();
    var new_pwd = $('#update_pwd_form').find('input[name="new_password"]').val();
    var retyped_pwd = $('#update_pwd_form').find('input[name="retyped_password"]').val();
    if (current_pwd == '') {
      event.preventDefault();
      $(".alert").empty();
      $(".alert").append("Current password field is empty. You need to enter your current password.");
      $(".alert").removeClass("alert alert-danger").addClass("alert alert-danger");
      return 0;
    }
    if (new_pwd == '') {
      event.preventDefault();
      $(".alert").empty();
      $(".alert").append("New password field is empty. You need to enter a new password.");
      $(".alert").removeClass("alert alert-danger").addClass("alert alert-danger");
      return 0;
    }
    if (retyped_pwd == '') {
      event.preventDefault();
      $(".alert").empty();
      $(".alert").append("Retype password field is empty. You need to retype your new password.");
      $(".alert").removeClass("alert alert-danger").addClass("alert alert-danger");
      return 0;
    }
    if (new_pwd != retyped_pwd) {
      event.preventDefault();
      $(".alert").empty();
      $(".alert").append("Passwords don't match. Please ensure retyped password matches your new password.");
      $(".alert").removeClass("alert alert-danger").addClass("alert alert-danger");
      return 0;
    }

    return 1;
  });

  $('#add_gfd_form').submit(function(event){
    var gene_name = $('#add_gfd_form').find('input[name="gene_name"]').val();
    var disease_name = $('#add_gfd_form').find('input[name="disease_name"]').val();
    if (gene_name == '') {
      event.preventDefault();
      $(".alert").empty();
      $(".alert").append("Please provide a gene name.");
      $(".alert").removeClass("alert alert-danger").addClass("alert alert-danger");
      return 0;
    }
    if (disease_name == '') {
      event.preventDefault();
      $(".alert").empty();
      $(".alert").append("Please provide a disease name.");
      $(".alert").removeClass("alert alert-danger").addClass("alert alert-danger");
      return 0;
    }
    return 1;
  });




});
