package com.charles.seek.config;

import com.charles.seek.dto.gear.request.AddGearDto;
import com.charles.seek.model.gear.GearModel;
import org.modelmapper.ModelMapper;
import org.modelmapper.PropertyMap;
import org.springframework.context.annotation.Configuration;

@Configuration
public class CustomModelMapperConfig {
    private final ModelMapper modelMapper;

    public CustomModelMapperConfig(ModelMapper modelMapper) {
        this.modelMapper = modelMapper;
        configureMappings();
    }

    private void configureMappings() {
        modelMapper.addMappings(new PropertyMap<AddGearDto, GearModel>() {
            @Override
            protected void configure() {
                map().setName(source.getName());
                //map().setRegistrationDate(source.getCreatedAt());
            }
        });



        // 地址映射
/*        modelMapper.typeMap(AddressDTO.class, com.example.entity.Address.class)
                .addMappings(mapper -> {
                    mapper.map(AddressDTO::getStreet, com.example.entity.Address::setStreetAddress);
                    mapper.map(AddressDTO::getCity, com.example.entity.Address::setCityName);
                    mapper.map(AddressDTO::getZipCode, com.example.entity.Address::setPostalCode);
                });*/
    }
}