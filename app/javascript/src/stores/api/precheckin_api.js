export default {
  list: (params) => {
    return window.$.ajax({
      url: `${process.env.MIX_ROOT_PATH}/user/precheckins`,
      method: 'GET',
      dataType: 'json',
      data: params,
      contentType: 'application/json',
      cache: false
    });
  }
};
