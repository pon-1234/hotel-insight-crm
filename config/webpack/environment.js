const {
  environment
} = require('@rails/webpacker');
const {
  VueLoaderPlugin
} = require('vue-loader');
const vue = require('./loaders/vue');
const dotenv = require('dotenv');
dotenv.config({ path: '.env', silent: true });
// config CkEditor5 
const CKEditorWebpackPlugin = require('@ckeditor/ckeditor5-dev-webpack-plugin');
const ckeditorSvgLoader = require('./loaders/ckeditor-svg');
const ckeditorCssLoader = require('./loaders/ckeditor-css');

const customConfig = require('./custom');

environment.config.merge(customConfig);

const webpack = require('webpack');
environment.plugins.append('Provide',
  new webpack.ProvidePlugin({
    $: 'jquery',
    jQuery: 'jquery',
    Popper: ['popper.js', 'default']
  })
);

environment.plugins.prepend('VueLoaderPlugin', new VueLoaderPlugin());

environment.plugins.prepend(
  'Environment',
  new webpack.EnvironmentPlugin(Object.assign({ MIX_ROOT_PATH: '' }, process.env))
);

environment.loaders.prepend('vue', vue);
// config CkEditor5 css
environment.plugins.prepend('CKEditorWebpackPlugin', new CKEditorWebpackPlugin({
  addMainLanguageTranslationsToAllAssets: true,
  buildAllTranslationsToSeparateFiles: true,
  language: 'en'
}));
environment.loaders.prepend('ckeditor-svg', ckeditorSvgLoader);
environment.loaders.prepend('ckeditor-css', ckeditorCssLoader);

environment.loaders.get('css').exclude = [
  /\.module\.[a-z]+$/,
  /ckeditor5-[^/]+\/theme\/[\w-/]+\.css$/
];
const fileLoader = environment.loaders.get('file');
fileLoader.exclude = /ckeditor5-[^/\\]+[/\\]theme[/\\]icons[/\\][^/\\]+\.svg$/;
const cssLoader = environment.loaders.get('css');
cssLoader.exclude = /(\.module\.[a-z]+$)|(ckeditor5-[^/\\]+[/\\]theme[/\\].+\.css)/;

module.exports = environment;
