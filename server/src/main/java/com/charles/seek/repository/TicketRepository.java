package com.charles.seek.repository;

import com.charles.seek.model.ticket.TicketModel;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface TicketRepository extends JpaRepository<TicketModel, Long> {
    List<TicketModel> findByOwnerOrderByDepartureTimeDesc(String owner);
    List<TicketModel> findByTravelNoOrderByDepartureTimeDesc(String travelNo);
}