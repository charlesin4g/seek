package com.charles.seek.service;

import com.charles.seek.model.ticket.TicketModel;
import com.charles.seek.dto.ticket.request.EditTicketRequest;

import java.util.List;
import java.util.Optional;

public interface TicketService {
    TicketModel save(TicketModel ticket);
    Optional<TicketModel> findById(Long id);
    List<TicketModel> findByOwner(String owner);
    List<TicketModel> findByTravelNo(String travelNo);
    void deleteById(Long id);
    // 新增：按ID编辑票据
    Optional<TicketModel> updateTicket(Long ticketId, EditTicketRequest req);
}