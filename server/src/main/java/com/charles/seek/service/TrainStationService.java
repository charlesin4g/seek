package com.charles.seek.service;

import com.charles.seek.model.ticket.TrainStationModel;
import java.util.List;
import java.util.Optional;

public interface TrainStationService {
    TrainStationModel save(TrainStationModel station);
    boolean existsByCode(String code);
    Optional<TrainStationModel> findByCode(String code);
    List<TrainStationModel> searchByKeyword(String keyword);
    List<TrainStationModel> listAllOrderedByName();
}