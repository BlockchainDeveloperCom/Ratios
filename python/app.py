import requests

def get_coins(symbol):
    url = 'https://api.coingecko.com/api/v3/coins/%s' % (symbol)
    headers = {'cache-control': 'no-cache'}
    response = requests.request('GET', url, headers=headers)

    if response.status_code != requests.codes.ok:
        print('Error performing API request.')
        return

    data = response.json()
    current_price_usd = data['market_data']['current_price']['usd']
    return current_price_usd

def calculate_ratio_of_coins(numeratorCoinSymbol, denominatorCoinSymbol):
    numeratorCoinCurrentPrice = get_coins(numeratorCoinSymbol)
    denominatorCoinCurrentPrice = get_coins(denominatorCoinSymbol)
    print(numeratorCoinSymbol + ' current price: ' + str(numeratorCoinCurrentPrice))
    print(denominatorCoinSymbol + ' current price: ' + str(denominatorCoinCurrentPrice))
    return numeratorCoinCurrentPrice / denominatorCoinCurrentPrice

if __name__ == '__main__':
    ratio = calculate_ratio_of_coins('gas', 'neo')
    print('ratio: ' + str(ratio))
