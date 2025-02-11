// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.2;

import "../CountryRegistry.sol";

contract RewardCalculator {

    // CountryRegistry kontratına erişim (ülke bilgilerini ve ziyaret kayıtlarını almak için)
    CountryRegistry public countryRegistry;

    /**
     * @dev CountryRegistry kontrat adresini parametre olarak alır.
     * @param _countryRegistry CountryRegistry kontrat adresi.
     */
    constructor(address _countryRegistry) {
        countryRegistry = CountryRegistry(_countryRegistry);
    }
    
    /**
     * @dev Oyuncunun tüm ziyaretleri için ödenen toplam token miktarına göre,
     *      erken ayrılma durumunda geri ödenecek tutarı hesaplar.
     *      Geri ödeme, toplam ziyaret maliyetinin %20'si kadardır.
     *
     * @param player Geri ödeme alınacak oyuncunun adresi.
     * @return refundAmount Geri ödenecek token miktarı.
     */
    function calculateRefund(address player) public view returns (uint256 refundAmount) {
        // CountryRegistry kontratındaki getTotalVisitCost fonksiyonu kullanılarak oyuncunun
        // ziyaret ettiği ülkeler için ödediği toplam token miktarı hesaplanır.
        uint256 totalVisitCost = countryRegistry.getTotalVisitCost(player);
        refundAmount = (totalVisitCost * 20) / 100;
    }
}
