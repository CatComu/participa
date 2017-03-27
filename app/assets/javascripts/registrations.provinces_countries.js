// change to provinces for a given country
function show_provinces(country_code, catalonia_resident){
  var select_id = '#js-registration-user_province-wrapper';
  var $select_wrapper = $(select_id);
  var url = '/registrations/regions/provinces?no_profile=1&user_country=' + country_code;

  if (!(catalonia_resident === undefined)) {
    url = url + '&user_catalonia_resident=' + catalonia_resident;
  }

  $('#user_town').disable_control();
  $('#user_postal_code').val('');

  $select_wrapper.load(url + ' ' + select_id + '> *', function() {
    var $prov_select = $('select#user_province');
    if ($prov_select.length > 0 && $prov_select.select2)
      $prov_select.select2();
  });
}

// change to provinces for a given country
function show_towns(parent, field, country_code, province_code, prefix){
  var select_id = '#js-registration-' + field + '-wrapper';
  var $select_wrapper = $(select_id);

  $('#' + field).disable_control();
  $('#user_postal_code').val('');
  if (province_code == '' || country_code != 'ES')
    return;

  var url = '/registrations/' + prefix + '/municipies?no_profile=1&user_country=ES&' + parent + '=' + province_code;

  $select_wrapper.load(url + ' ' + select_id + '> *', function() {
    var $town_select = $('select#' + field);
    if ($town_select.select2)
      $town_select.select2();

    if (field == 'user_town') {
      var options = $town_select.children('option');
      if (options.length > 1) {
        var postal_code = $('#user_postal_code').val();
        var prefix = options[1].value.substr(2,2);
        if (postal_code.length < 5 || postal_code.substr(0, 2) != prefix) {
          $('#user_postal_code').val(prefix);
        }
      }
    }
  });
}

function toggle_vote_town(country) {
  $('#vote_town_section').toggle(country != 'ES');
}

var can_change_vote_location;

$(function() {
  can_change_vote_location = !$('select#user_vote_province').is(':disabled');

  var $country = $('select#user_country');
  var $catalonia_resident = $('#user_catalonia_resident');

  if ($country.length) {
    $.fn.disable_control = function( ) {
      if (this.data('select2'))
        this.select2('readonly', true).select2('val', '').attr('data-placeholder', '-').select2();
      else
        this.prop('readonly', true).val('').attr('placeholder', '-');
      return this;
    };

    $country.on('change', function() {
      var country_code = $(this).val();
      if (can_change_vote_location) toggle_vote_town(country_code);
      show_provinces( country_code, $catalonia_resident.is(':checked') ? '1' : '0' );
    });

    $(document.body).on('change', 'select#user_province', function() {
      show_towns( 'user_province', 'user_town', $country.val(), $(this).val(), 'regions' );
    });

    if (can_change_vote_location) {
      toggle_vote_town($country.val());
      $('select#user_vote_province').on('change', function() {
        show_towns( 'user_vote_province', 'user_vote_town', 'ES', $(this).val(), 'vote' );
      });
      if ($('select#user_vote_province').val() == '-' || $('select#user_vote_town').is(':disabled')) {
        $('select#user_vote_province').trigger('change');
      }
    } else {
      toggle_vote_town(false);
    }

    if ($country.find(':selected').val() != 'ES') {
      $('#user_town').disable_control();
    }
  }

  var $country_group = $country.parents('.inputlabel-box');

  if ($catalonia_resident.is(':checked')) {
    $country_group.hide();
  }

  $catalonia_resident.click(function() {
    if (this.checked) {
      show_provinces( 'ES', '1' );
      $country.val('ES');
      $country_group.hide();
    } else {
      show_provinces( $country.find(':selected').val(), '0' );
      $country_group.show();
    }
  });
});
