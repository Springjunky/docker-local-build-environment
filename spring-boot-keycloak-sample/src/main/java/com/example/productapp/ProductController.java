package com.example.productapp;

import java.security.Principal;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
class ProductController {

   @Autowired ProductService productService;

   
   @GetMapping(path = "/products")
   public String getProducts(Principal principal, Model model){
      model.addAttribute("principal",principal);
      model.addAttribute("products", productService.getProducts());
      return "products";
   }
   
   @GetMapping(path = "/logout")
   public String logout(HttpServletRequest request) throws ServletException {
      request.logout();
      return "/";
   }
}