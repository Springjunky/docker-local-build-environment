package com.example.productapp;

import java.util.Arrays;
import java.util.List;

import org.springframework.stereotype.Component;

@Component
class ProductService {
   public List<String> getProducts() {
      return Arrays.asList("iPad","iPod","iPhone");
   }
}