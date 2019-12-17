const path = require('path')
const glob = require('glob')
const MiniCssExtractPlugin = require('mini-css-extract-plugin')
const TerserPlugin = require('terser-webpack-plugin')
const OptimizeCSSAssetsPlugin = require('optimize-css-assets-webpack-plugin')
const CopyWebpackPlugin = require('copy-webpack-plugin')

const prodOutput = {
  filename: 'app.js',
  path: path.resolve(__dirname, '../priv/static/js'),
  publicPath: '/'
}

const devOutput = {
  filename: 'js/app.js',
  path: path.resolve(__dirname, 'public'),
  publicPath: 'http://localhost:8080/public'
}

module.exports = (env, options) => ({
  optimization: {
    minimizer: [
      new TerserPlugin({ cache: true, parallel: true, sourceMap: false }),
      new OptimizeCSSAssetsPlugin({})
    ]
  },
  entry: {
    './js/app.js': glob.sync('./vendor/**/*.js').concat(['./js/app.js'])
  },
  devServer: {
    headers: {
      'Access-Control-Allow-Origin': '*'
    },
    // writeToDisk: true,
    publicPath: '/public',
    watchContentBase: true,
    overlay: true
  },
  output: options.mode === 'development' ? devOutput : prodOutput,
  module: {
    rules: [
      {
        test: /\.elm$/,
        exclude: [/elm-stuff/, /node_modules/],
        use: {
          loader: 'elm-webpack-loader',
          options: {
            debug: options.mode === 'development',
            pathToElm: 'node_modules/.bin/elm'
          }
        }
      },
      {
        test: /\.js$/,
        exclude: /node_modules/,
        use: {
          loader: 'babel-loader'
        }
      },
      {
        test: /\.css$/,
        use: [MiniCssExtractPlugin.loader, 'css-loader']
      }
    ]
  },
  plugins: [
    new MiniCssExtractPlugin({ filename: 'css/app.css' }),
    new CopyWebpackPlugin([{ from: 'static/', to: './' }])
  ]
})
