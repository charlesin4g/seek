package com.charles.seek.repository;

import com.charles.seek.model.ticket.AirportModel;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.Optional;

@Repository
public interface AirportRepository extends JpaRepository<AirportModel, Long> {
  boolean existsByIataCode(String iataCode);
  Optional<AirportModel> findByIataCode(String iataCode);
}